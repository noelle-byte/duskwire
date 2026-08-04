#!/usr/bin/env python3
"""Build an XCursor theme from Hyprcursor SVG sources and meta.hl files."""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


FLOAT_FIELD = re.compile(
    r"^\s*(hotspot_[xy])\s*=\s*([0-9]*\.?[0-9]+)\s*$",
    re.MULTILINE,
)
DEFINE_SIZE = re.compile(r"^\s*define_size\s*=\s*(.+?)\s*$", re.MULTILINE)
DEFINE_OVERRIDE = re.compile(
    r"^\s*define_override\s*=\s*([A-Za-z0-9_.+-]+)\s*$",
    re.MULTILINE,
)


class BuildError(RuntimeError):
    pass


def parse_sizes(raw: str) -> list[int]:
    try:
        sizes = sorted({int(part.strip()) for part in raw.split(",") if part.strip()})
    except ValueError as exc:
        raise argparse.ArgumentTypeError("sizes must be comma-separated integers") from exc

    if not sizes or any(size <= 0 for size in sizes):
        raise argparse.ArgumentTypeError("sizes must contain positive integers")
    return sizes


def read_metadata(meta_path: Path) -> tuple[float, float, list[tuple[Path, int | None]], list[str]]:
    text = meta_path.read_text(encoding="utf-8")

    fields = dict(FLOAT_FIELD.findall(text))
    if "hotspot_x" not in fields or "hotspot_y" not in fields:
        raise BuildError(f"{meta_path}: missing hotspot_x or hotspot_y")

    hotspot_x = float(fields["hotspot_x"])
    hotspot_y = float(fields["hotspot_y"])
    if not (0.0 <= hotspot_x <= 1.0 and 0.0 <= hotspot_y <= 1.0):
        raise BuildError(f"{meta_path}: hotspots must be between 0 and 1")

    frames: list[tuple[Path, int | None]] = []
    for definition in DEFINE_SIZE.findall(text):
        parts = [part.strip() for part in definition.split(",")]
        if len(parts) < 2:
            raise BuildError(f"{meta_path}: invalid define_size line: {definition!r}")

        source_file = meta_path.parent / parts[1]
        if not source_file.is_file():
            raise BuildError(f"{meta_path}: source image does not exist: {source_file}")

        delay: int | None = None
        if len(parts) >= 3 and parts[2]:
            try:
                delay = int(parts[2])
            except ValueError as exc:
                raise BuildError(
                    f"{meta_path}: invalid animation delay in {definition!r}"
                ) from exc

        frames.append((source_file, delay))

    if not frames:
        raise BuildError(f"{meta_path}: no define_size entries")

    aliases = DEFINE_OVERRIDE.findall(text)
    return hotspot_x, hotspot_y, frames, aliases


def run_checked(command: list[str]) -> None:
    try:
        subprocess.run(command, check=True)
    except FileNotFoundError as exc:
        raise BuildError(f"required command not found: {command[0]}") from exc
    except subprocess.CalledProcessError as exc:
        raise BuildError(f"command failed with status {exc.returncode}: {' '.join(command)}") from exc


def render_svg(source: Path, output: Path, size: int) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    run_checked(
        [
            "rsvg-convert",
            "--format=png",
            f"--width={size}",
            f"--height={size}",
            "--keep-aspect-ratio",
            f"--output={output}",
            str(source),
        ]
    )


def safe_alias(cursors_dir: Path, alias: str, target: str) -> None:
    if alias == target:
        return

    alias_path = cursors_dir / alias
    if alias_path.exists() or alias_path.is_symlink():
        if alias_path.is_symlink() and os.readlink(alias_path) == target:
            return
        if alias_path.is_file() and not alias_path.is_symlink():
            return
        raise BuildError(f"conflicting alias {alias!r}")

    alias_path.symlink_to(target)


def build_cursor(
    cursor_dir: Path,
    cursors_dir: Path,
    sizes: list[int],
    work_root: Path,
) -> tuple[str, list[str]]:
    cursor_name = cursor_dir.name
    meta_path = cursor_dir / "meta.hl"
    hotspot_x, hotspot_y, frames, aliases = read_metadata(meta_path)

    cursor_work = work_root / cursor_name
    cursor_work.mkdir(parents=True, exist_ok=True)
    config_path = cursor_work / "cursor.conf"

    config_lines: list[str] = []
    animated = len(frames) > 1

    for size in sizes:
        hot_x = min(size - 1, max(0, round(hotspot_x * (size - 1))))
        hot_y = min(size - 1, max(0, round(hotspot_y * (size - 1))))

        for frame_index, (source, declared_delay) in enumerate(frames):
            png_path = cursor_work / f"{size}-{frame_index:03d}.png"
            render_svg(source, png_path, size)

            if animated:
                delay = declared_delay if declared_delay is not None else 100
                config_lines.append(f"{size} {hot_x} {hot_y} {png_path} {delay}")
            else:
                config_lines.append(f"{size} {hot_x} {hot_y} {png_path}")

    config_path.write_text("\n".join(config_lines) + "\n", encoding="utf-8")
    run_checked(["xcursorgen", str(config_path), str(cursors_dir / cursor_name)])
    return cursor_name, aliases


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument(
        "--sizes",
        default="24,32,48,64,96",
        type=parse_sizes,
        help="comma-separated XCursor sizes",
    )
    args = parser.parse_args()

    source: Path = args.source.resolve()
    output: Path = args.output.resolve()
    sizes: list[int] = args.sizes

    if not source.is_dir():
        raise BuildError(f"source directory not found: {source}")

    cursor_sources = sorted(
        path for path in source.iterdir() if path.is_dir() and (path / "meta.hl").is_file()
    )
    if not cursor_sources:
        raise BuildError(f"no cursor source directories found in {source}")

    cursors_dir = output / "cursors"
    if cursors_dir.exists():
        shutil.rmtree(cursors_dir)
    cursors_dir.mkdir(parents=True)

    aliases_by_cursor: dict[str, list[str]] = {}
    with tempfile.TemporaryDirectory(prefix="duskwire-xcursor-") as tmp:
        work_root = Path(tmp)
        for cursor_source in cursor_sources:
            name, aliases = build_cursor(cursor_source, cursors_dir, sizes, work_root)
            aliases_by_cursor[name] = aliases
            print(f"built {name}", file=sys.stderr)

    for target, aliases in aliases_by_cursor.items():
        for alias in aliases:
            safe_alias(cursors_dir, alias, target)

    required = ("left_ptr", "default", "xterm", "hand2")
    missing = [name for name in required if not (cursors_dir / name).exists()]
    if missing:
        raise BuildError(f"generated theme is missing required cursors: {', '.join(missing)}")

    (output / "index.theme").write_text(
        "[Icon Theme]\n"
        "Name=noelle-twilight-hyprcursor\n"
        "Comment=Noelle Twilight cursor theme for Hyprcursor and XCursor\n"
        "Inherits=hicolor\n",
        encoding="utf-8",
    )

    print(
        f"built {len(cursor_sources)} XCursor definitions at {cursors_dir}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BuildError as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)
