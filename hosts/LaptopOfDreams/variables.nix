{
  username = "noelle";
  hostname = "LaptopOfDreams";
  system = "x86_64-linux";

  # Duskwire's editable checkout. The global `duskwire` command uses this.
  repoPath = "/home/noelle/Projects/Duskwire";

  # Never raise these casually. They represent the first compatible release.
  systemStateVersion = "26.05";
  homeStateVersion = "26.05";

  features = {
    bluetooth = true;
    development = true;
    flatpak = false;
    gaming = true;
    maintenance = true;
    printing = true;
    powerProfiles = true;
    ssh = false;
    syncthing = false;
    virtualisation = false;
  };
}
