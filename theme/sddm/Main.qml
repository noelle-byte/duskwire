import QtQuick 2.15
import QtQml 2.15
import SddmComponents 2.0

Rectangle {
    id: root

    width: 1920
    height: 1080
    color: config.stringValue("Night")

    property date currentTime: new Date()
    property string loginUser: userModel.lastUser.length > 0
        ? userModel.lastUser
        : "noelle"
    property int sessionIndex: session.index

    function submitLogin() {
        statusText.color = config.stringValue("Muted")
        statusText.text = "Opening your session..."

        sddm.login(
            root.loginUser,
            password.text,
            root.sessionIndex
        )
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentTime = new Date()
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            password.text = ""
            statusText.color = config.stringValue("Amber")
            statusText.text = "That password did not work."
            password.forceActiveFocus()
        }

        function onLoginSucceeded() {
            statusText.color = config.stringValue("Cream")
            statusText.text = "Welcome home."
        }

        function onInformationMessage(message) {
            statusText.color = config.stringValue("Amber")
            statusText.text = message
        }
    }


    // ---------------------------------------------------------
    // Background
    // ---------------------------------------------------------

    Image {
        anchors.fill: parent

        source:
            Qt.resolvedUrl(
                config.stringValue("Background")
            )

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }

    Rectangle {
        anchors.fill: parent

        color: config.stringValue("Night")
        opacity: 0.18
    }


    // ---------------------------------------------------------
    // Clock
    // ---------------------------------------------------------

    Column {
        anchors.horizontalCenter:
            parent.horizontalCenter

        anchors.top: parent.top
        anchors.topMargin: 72

        spacing: 2

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text:
                Qt.formatDateTime(
                    root.currentTime,
                    "HH:mm"
                )

            color: config.stringValue("Cream")

            font.family:
                "CaskaydiaCove Nerd Font"

            font.pixelSize: 64
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text:
                Qt.formatDateTime(
                    root.currentTime,
                    "dddd, d MMMM"
                )

            color: config.stringValue("Text")

            font.family:
                "CaskaydiaCove Nerd Font"

            font.pixelSize: 17
        }
    }


    // ---------------------------------------------------------
    // Login card
    // ---------------------------------------------------------

    Item {
        id: cardContainer

        width: 450
        height: 350

        anchors.centerIn: parent
        anchors.verticalCenterOffset: 45


        // Soft shadow

        Rectangle {
            anchors.fill: parent

            anchors.leftMargin: 9
            anchors.topMargin: 11
            anchors.rightMargin: -9
            anchors.bottomMargin: -11

            radius: 30

            color: config.stringValue("Shadow")
            opacity: 0.55
        }


        // Card background

        Rectangle {
            anchors.fill: parent

            radius: 30

            color: config.stringValue("Night")
            opacity: 0.92
        }


        // Card outline

        Rectangle {
            anchors.fill: parent

            radius: 30
            color: "transparent"

            border.width: 2
            border.color:
                config.stringValue("Lavender")
        }


        Column {
            anchors.fill: parent
            anchors.margins: 34

            spacing: 14


            Text {
                width: parent.width

                text: "Welcome home, Noelle"

                color:
                    config.stringValue("Cream")

                font.family:
                    "CaskaydiaCove Nerd Font"

                font.pixelSize: 25
                font.weight: Font.DemiBold

                horizontalAlignment:
                    Text.AlignHCenter
            }


            Text {
                width: parent.width

                text:
                    root.loginUser
                    + "  ·  "
                    + sddm.hostName

                color:
                    config.stringValue("Muted")

                font.family:
                    "CaskaydiaCove Nerd Font"

                font.pixelSize: 13

                horizontalAlignment:
                    Text.AlignHCenter
            }


            Item {
                width: 1
                height: 5
            }


            // Password field

            Rectangle {
                width: parent.width
                height: 54

                radius: 15

                color:
                    config.stringValue("Shadow")

                border.width: 2

                border.color:
                    password.activeFocus
                        ? config.stringValue("Amber")
                        : config.stringValue("Lavender")


                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 17

                    visible:
                        password.text.length === 0

                    text: "Password"

                    color:
                        config.stringValue("Muted")

                    verticalAlignment:
                        Text.AlignVCenter

                    font.family:
                        "CaskaydiaCove Nerd Font"

                    font.pixelSize: 15
                }


                TextInput {
                    id: password

                    anchors.fill: parent
                    anchors.margins: 16

                    color:
                        config.stringValue("Text")

                    selectionColor:
                        config.stringValue("Violet")

                    selectedTextColor:
                        config.stringValue("Cream")

                    echoMode:
                        TextInput.Password

                    passwordCharacter: "●"

                    verticalAlignment:
                        TextInput.AlignVCenter

                    selectByMouse: true

                    font.family:
                        "CaskaydiaCove Nerd Font"

                    font.pixelSize: 15

                    Keys.onPressed:
                        function(event) {
                            if (
                                event.key === Qt.Key_Return
                                || event.key === Qt.Key_Enter
                            ) {
                                root.submitLogin()
                                event.accepted = true
                            }
                        }
                }
            }


            // Login button

            Rectangle {
                width: parent.width
                height: 52

                radius: 15

                color:
                    loginMouse.containsMouse
                        ? config.stringValue("Amber")
                        : config.stringValue("Indigo")

                border.width: 1

                border.color:
                    loginMouse.containsMouse
                        ? config.stringValue("Cream")
                        : config.stringValue("Lavender")


                Text {
                    anchors.centerIn: parent

                    text: "Enter"

                    color:
                        loginMouse.containsMouse
                            ? config.stringValue("Night")
                            : config.stringValue("Cream")

                    font.family:
                        "CaskaydiaCove Nerd Font"

                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }


                MouseArea {
                    id: loginMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.submitLogin()
                }
            }


            Text {
                id: statusText

                width: parent.width
                height: 20

                text: "Enter your password to continue"

                color:
                    config.stringValue("Muted")

                font.family:
                    "CaskaydiaCove Nerd Font"

                font.pixelSize: 12

                horizontalAlignment:
                    Text.AlignHCenter

                verticalAlignment:
                    Text.AlignVCenter
            }


            // Session selector

            Item {
                width: parent.width

                height:
                    sessionModel.count > 1
                        ? 38
                        : 0

                visible:
                    sessionModel.count > 1


                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter:
                        parent.verticalCenter

                    text: "Session"

                    color:
                        config.stringValue("Muted")

                    font.family:
                        "CaskaydiaCove Nerd Font"

                    font.pixelSize: 12
                }


                ComboBox {
                    id: session

                    anchors.right: parent.right
                    anchors.verticalCenter:
                        parent.verticalCenter

                    width: 235
                    height: 34

                    model: sessionModel
                    index: sessionModel.lastIndex

                    font.pixelSize: 12
                }
            }
        }
    }


    // ---------------------------------------------------------
    // System controls
    // ---------------------------------------------------------

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 28
        anchors.bottomMargin: 24

        spacing: 10


        Rectangle {
            width: 112
            height: 42

            radius: 13

            color:
                rebootMouse.containsMouse
                    ? config.stringValue("Amber")
                    : config.stringValue("Night")

            border.width: 1
            border.color:
                config.stringValue("Lavender")

            visible: sddm.canReboot


            Text {
                anchors.centerIn: parent

                text: "↻  Restart"

                color:
                    rebootMouse.containsMouse
                        ? config.stringValue("Night")
                        : config.stringValue("Text")

                font.family:
                    "CaskaydiaCove Nerd Font"

                font.pixelSize: 13
            }


            MouseArea {
                id: rebootMouse

                anchors.fill: parent
                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onClicked:
                    sddm.reboot()
            }
        }


        Rectangle {
            width: 124
            height: 42

            radius: 13

            color:
                powerMouse.containsMouse
                    ? config.stringValue("Amber")
                    : config.stringValue("Night")

            border.width: 1
            border.color:
                config.stringValue("Lavender")

            visible: sddm.canPowerOff


            Text {
                anchors.centerIn: parent

                text: "⏻  Power off"

                color:
                    powerMouse.containsMouse
                        ? config.stringValue("Night")
                        : config.stringValue("Text")

                font.family:
                    "CaskaydiaCove Nerd Font"

                font.pixelSize: 13
            }


            MouseArea {
                id: powerMouse

                anchors.fill: parent
                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onClicked:
                    sddm.powerOff()
            }
        }
    }


    Component.onCompleted: {
        password.forceActiveFocus()
    }
}
