import Qt5Compat.GraphicalEffects
import QtQml 2.15
import QtQuick 2.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

// import org.kde.plasma.private.quicklaunch 1.0
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kcmutils as KCM
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kquickcontrolsaddons 2.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.plasma.private.sessions as Sessions

RowLayout {
    id: headComponent
    width: (rootItem.resizeWidth() == 0 ? rootItem.spaceWidth : rootItem.resizeWidth())

    SequentialAnimation {
        running: true
        loops: Animation.Infinite

        PropertyAnimation {
            target: alo_user
            property: "opacity"
            from: 0.2
            to: 0.8
            duration: 2000
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: alo_user
            property: "opacity"
            from: 0.8
            to: 0.2
            duration: 2000
            easing.type: Easing.InOutQuad
        }

    }

    Rectangle {
        width: 60
        color: "transparent"
    }

    Item {
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        visible: iconUser.source !== "" && Plasmoid.configuration.showHeader

        Rectangle {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            width: kicker.sizeImage * 0.83
            height: width
            color: "transparent"

            Rectangle {
                id: alo_user
                anchors.centerIn: parent
                width: kicker.sizeImage * 0.83
                height: width
                color: "white"
                radius: userShape
                clip: true // This clips rectangle's contents
                visible: iconUser.source !== "" && Plasmoid.configuration.showHeader
                z: 1

                Rectangle {
                    id: mask2
                    width: parent.width
                    height: parent.height
                    visible: false
                    radius: userShape
                }

                Image {
                    id: iconUser2
                    width: parent.width
                    height: parent.height
                    source: kuser.faceIconUrl
                    cache: false
                    visible: source !== "" && Plasmoid.configuration.showHeader
                    sourceSize.width: kicker.sizeImage
                    sourceSize.height: kicker.sizeImage
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true

                    layer.effect: OpacityMask {
                        maskSource: mask2
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: kicker.sizeImage * 0.7
                height: width
                color: "transparent"
                z: 2
                radius: userShape
                clip: true // This clips rectangle's contents
                visible: iconUser.source !== "" && Plasmoid.configuration.showHeader

                Rectangle {
                    id: mask
                    width: parent.width
                    height: parent.height
                    visible: false
                    radius: userShape
                }

                Image {
                    id: iconUser
                    width: parent.width
                    height: parent.height
                    source: kuser.faceIconUrl
                    cache: false
                    visible: source !== "" && Plasmoid.configuration.showHeader
                    sourceSize.width: kicker.sizeImage
                    sourceSize.height: kicker.sizeImage
                    fillMode: Image.PreserveAspectFit

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: mask
                    }

                    transitions: Transition {
                        PropertyAnimation {
                            properties: "opacity,y"
                            easing.type: Easing.InOutQuad
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton
                        onClicked: KCM.KCMLauncher.openSystemSettings("kcm_users")
                    }
                }
            }
        }

        Kirigami.Heading {
            id: textouser
            visible: iconUser.source !== "" && Plasmoid.configuration.showHeader
            Layout.alignment: Qt.AlignVCenter
            color: Kirigami.Theme.textColor
            level: 4
            text: i18n("Hola, ") + kuser.fullName
            font.weight: Font.Bold
        }

        TextMetrics {
            id: headingMetrics
        }
    }

    Item {
        Layout.fillWidth: true
    }

    PC3.ToolButton {
        id: configureButton
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        visible: (
            Plasmoid.internalAction("configure").enabled
            || (iconUser.source !== "" && Plasmoid.configuration.showHeader)
        )
        icon.name: "configure"
        text: Plasmoid.internalAction("configure").text
        display: PC3.ToolButton.IconOnly
        PC3.ToolTip.text: text
        PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
        PC3.ToolTip.visible: hovered
        onClicked: plasmoid.internalAction("configure").trigger()
    }

    PC3.ToolButton {
        id: pinButton
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        visible: (
            iconUser.source !== "" && Plasmoid.configuration.showHeader
        )
        checkable: true
        checked: Plasmoid.configuration.pin
        icon.name: "window-pin"
        text: i18n("Keep Open")
        display: PC3.ToolButton.IconOnly
        PC3.ToolTip.text: text
        PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
        PC3.ToolTip.visible: hovered
        onToggled: Plasmoid.configuration.pin = checked
        Binding {
            // There should be no other bindings, so don't waste resources
            target: kicker
            property: "hideOnWindowDeactivate"
            value: !Plasmoid.configuration.pin
        }
    }
}
