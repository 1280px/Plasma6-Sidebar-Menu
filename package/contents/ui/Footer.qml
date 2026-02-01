
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kquickcontrolsaddons 2.0
//import org.kde.plasma.private.quicklaunch 1.0
import QtQuick.Controls 2.15
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasma5support 2.0 as P5Support
import Qt5Compat.GraphicalEffects
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQml 2.15
import org.kde.kirigami 2.0  as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM
import org.kde.plasma.private.sessions as Sessions

RowLayout
{
    id:footerComponent
    width: (rootItem.resizeWidth()  == 0 ? rootItem.calc_width : rootItem.resizeWidth())
    Sessions.SessionManagement
    {
        id: cmd_desk
    }
    //cmd commands
    P5Support.DataSource
    {   id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }
    RowLayout
    {
    Layout.alignment: Qt.AlignHcenter | Qt.AlignBottom
    Item { Layout.fillWidth: true}
            PC3.ToolButton
            {
                icon.name:   "system-shutdown"
                onClicked: cmd_desk.requestShutdown()
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Leave ...")
                visible: true !== "" && Plasmoid.configuration.shutDownEnabled
            }
            PC3.ToolButton
            {
                icon.name:   "system-reboot"
                visible:  true !== "" && Plasmoid.configuration.rebootEnabled
                onClicked: cmd_desk.requestReboot() //executable.exec(restartCMD)
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Reboot ...")
            }

            PC3.ToolButton
            {
                icon.name:  "system-log-out"
                visible:  true !== "" && Plasmoid.configuration.logOutEnabled
                onClicked: cmd_desk.requestLogout()//executable.exec(logOutCMD);
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Log Out")
            }

            PC3.ToolButton
            {
                icon.name: "system-suspend"
                visible: true !== "" && Plasmoid.configuration.sleepEnabled // Asegúrate de tener la configuración para habilitar la hibernación
                onClicked: cmd_desk.suspend() // Comando para hibernar el sistema
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Hibernate")
            }
            PC3.ToolButton
            {
                icon.name:  "system-lock-screen"
                visible:  true !== "" && Plasmoid.configuration.lockScreenEnabled
                onClicked: cmd_desk.lock()
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Lock Screen")
            }
            PC3.ToolButton
            {
                icon.name: "dialog-error" // Icono de error
                visible: true !== "" && Plasmoid.configuration.forceQuitEnabled
                onClicked: executable.exec(forceQuitCMD) // Ejecuta xkill para forzar el cierre
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Force Close ...")
            }
            PC3.ToolButton
            {
                icon.name:  "user-home"
                visible:  true !== "" && Plasmoid.configuration.homeEnabled
                onClicked: executable.exec(homeCMD);
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("User Home")
            }
            PC3.ToolButton
            {
                icon.name: "system-software-install" // Ícono asociado con Plasma Discover
                visible: true !== "" && Plasmoid.configuration.appStoreEnabled
                onClicked: executable.exec(appStoreCMD) // Comando para abrir Plasma Discover
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Open Plasma Discover")
            }
            PC3.ToolButton
            {
                icon.name:  "configure"
                visible:  true !== "" && Plasmoid.configuration.systemPreferencesEnabled
                onClicked: executable.exec(systemPreferencesCMD);
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("System Preferences")
            }
            PC3.ToolButton
            {
                icon.name: "info"
                visible: true !== "" && Plasmoid.configuration.aboutThisComputerEnabled
                onClicked: { movePopupController.movePopup(100, 100)  /* Llama a la función de C++*/ }//executable.exec(aboutThisComputerCMD)
                ToolTip.delay: 200
                ToolTip.timeout: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("About System")
            }
       Item { Layout.fillWidth: true }
       }
    }

