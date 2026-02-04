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
    width: (rootItem.resizeWidth() == 0 ? rootItem.spaceWidth : rootItem.resizeWidth())

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
        Item {
            Layout.fillWidth: true
        }

        PC3.ToolButton {
            icon.name: "system-shutdown"
            onClicked: cmd_desk.requestShutdown()
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Shut Down")
            visible: true !== "" && Plasmoid.configuration.shutDownEnabled
        }

        PC3.ToolButton {
            icon.name: "system-reboot"
            visible: true !== "" && Plasmoid.configuration.rebootEnabled
            onClicked: cmd_desk.requestReboot() // executable.exec(restartCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Reboot")
        }

        PC3.ToolButton {
            icon.name: "system-log-out"
            visible: true !== "" && Plasmoid.configuration.logOutEnabled
            onClicked: cmd_desk.requestLogout() // executable.exec(logOutCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Log Out")
        }

        PC3.ToolButton {
            icon.name: "system-suspend"
            visible: true !== "" && Plasmoid.configuration.sleepEnabled
            onClicked: cmd_desk.suspend()
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Hibernate")
        }

        PC3.ToolButton {
            icon.name: "system-lock-screen"
            visible: true !== "" && Plasmoid.configuration.lockScreenEnabled
            onClicked: cmd_desk.lock()
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Lock Screen")
        }

        PC3.ToolButton {
            icon.name: "user-home-symbolic"
            visible: true !== "" && Plasmoid.configuration.homeEnabled
            onClicked: executable.exec(homeCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("User Home")
        }

        PC3.ToolButton {
            icon.name: "folder-downloads-symbolic"
            visible: true !== "" && Plasmoid.configuration.downloadsEnabled
            onClicked: executable.exec(downloadsCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Downloads")
        }

        PC3.ToolButton {
            icon.name: "user-desktop-symbolic"
            visible: true !== "" && Plasmoid.configuration.desktopEnabled
            onClicked: executable.exec(desktopCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Desktop")
        }

        PC3.ToolButton {
            icon.name: "configure"
            visible: true !== "" && Plasmoid.configuration.systemPreferencesEnabled
            onClicked: executable.exec(systemPreferencesCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("System Preferences")
        }

        PC3.ToolButton {
            icon.name: "info"
            visible: true !== "" && Plasmoid.configuration.aboutThisComputerEnabled
            onClicked: { movePopupController.movePopup(100, 100) } // executable.exec(aboutThisComputerCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("About This PC")
        }

        PC3.ToolButton {
            icon.name: "kmenuedit"
            visible: true !== "" && Plasmoid.configuration.editApplicationsEnabled
            onClicked: executable.exec("kmenuedit")
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Edit Applications")
        }

        PC3.ToolButton {
            icon.name: "process-stop-symbolic"
            visible: true !== "" && Plasmoid.configuration.forceQuitEnabled
            onClicked: executable.exec(forceQuitCMD)
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Force Quit App")
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
