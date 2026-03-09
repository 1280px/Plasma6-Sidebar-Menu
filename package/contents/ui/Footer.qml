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
    id: footerComponent
    // width: rootItem.spaceWidth
    spacing: Kirigami.Units.smallSpacing

    Sessions.SessionManagement {
        id: cmd_desk
    }

    // Commands exectuion handler
    P5Support.DataSource {
        id: executable
        signal exited(
            string cmd, int exitCode, int exitStatus, string stdout, string stderr
        )
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd);
            }
        }
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"];
            var exitStatus = data["exit status"];
            var stdout = data["stdout"];
            var stderr = data["stderr"];
            exited(sourceName, exitCode, exitStatus, stdout, stderr);
            disconnectSource(sourceName);
        }
    }

    RowLayout {
        PC3.ToolButton {
            icon.name: "system-shutdown"
            onClicked: cmd_desk.requestShutdown()
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Shut Down")
            visible: Plasmoid.configuration.shutDownEnabled
        }

        PC3.ToolButton {
            icon.name: "system-reboot"
            visible: Plasmoid.configuration.rebootEnabled
            onClicked: cmd_desk.requestReboot() // executable.exec(restartCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Reboot")
        }

        PC3.ToolButton {
            icon.name: "system-log-out"
            visible: Plasmoid.configuration.logOutEnabled
            onClicked: cmd_desk.requestLogout() // executable.exec(logOutCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Log Out")
        }

        PC3.ToolButton {
            icon.name: "system-suspend"
            visible: Plasmoid.configuration.sleepEnabled
            onClicked: cmd_desk.suspend()
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Hibernate")
        }

        PC3.ToolButton {
            icon.name: "system-lock-screen"
            visible: Plasmoid.configuration.lockScreenEnabled
            onClicked: cmd_desk.lock()
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Lock Screen")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            visible: (
                (Plasmoid.configuration.homeEnabled ? 1 : 0)
                + (Plasmoid.configuration.downloadsEnabled ? 1 : 0)
                + (Plasmoid.configuration.desktopEnabled ? 1 : 0)
            ) >= 2 // Do not show if only one item from category is enabled
        }

        PC3.ToolButton {
            icon.name: "user-home-symbolic"
            visible: Plasmoid.configuration.homeEnabled
            onClicked: executable.exec(homeCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("User Home")
        }

        PC3.ToolButton {
            icon.name: "folder-downloads-symbolic"
            visible: Plasmoid.configuration.downloadsEnabled
            onClicked: executable.exec(downloadsCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Downloads")
        }

        PC3.ToolButton {
            icon.name: "user-desktop-symbolic"
            visible: Plasmoid.configuration.desktopEnabled
            onClicked: executable.exec(desktopCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Desktop")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            visible: (
                (Plasmoid.configuration.systemPreferencesEnabled ? 1 : 0)
                + (Plasmoid.configuration.aboutThisComputerEnabled ? 1 : 0)
                + (Plasmoid.configuration.editApplicationsEnabled ? 1 : 0)
                + (Plasmoid.configuration.forceQuitEnabled ? 1 : 0)
                + (Plasmoid.configuration.keepOpenEnabled ? 1 : 0)
            ) >= 2 // Do not show if only one item from category is enabled
        }

        PC3.ToolButton {
            icon.name: "configure"
            visible: Plasmoid.configuration.systemPreferencesEnabled
            onClicked: executable.exec(systemPreferencesCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("System Preferences")
        }

        PC3.ToolButton {
            icon.name: "info"
            visible: Plasmoid.configuration.aboutThisComputerEnabled
            onClicked: { movePopupController.movePopup(100, 100) } // executable.exec(aboutThisComputerCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("About This PC")
        }

        PC3.ToolButton {
            icon.name: "kmenuedit"
            visible: Plasmoid.configuration.editApplicationsEnabled
            onClicked: executable.exec("kmenuedit")
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Edit Applications")
        }

        PC3.ToolButton {
            icon.name: "process-stop-symbolic"
            visible: Plasmoid.configuration.forceQuitEnabled
            onClicked: executable.exec(forceQuitCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Force Quit App")
        }

        PC3.ToolButton {
            id: pinButton
            visible: Plasmoid.configuration.keepOpenEnabled
            checkable: true
            checked: Plasmoid.configuration.pin
            icon.name: "window-pin"
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Keep Open")
            onToggled: Plasmoid.configuration.pin = checked
            Binding {
                target: kicker
                property: "hideOnWindowDeactivate"
                value: !Plasmoid.configuration.pin
            }
        }
    }
}
