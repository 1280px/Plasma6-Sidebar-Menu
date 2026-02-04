
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM

import org.kde.plasma.workspace.dbus as DBus

KCM.SimpleKCM {
    id: configFooter
    // property alias cfg_showFooter: showFooter.value
    property alias cfg_transparencyFooter: transparencyFooter.value
    property alias cfg_shutDownEnabled: shutDownEnabled.checked
    property alias cfg_rebootEnabled: rebootEnabled.checked
    property alias cfg_logOutEnabled: logOutEnabled.checked
    property alias cfg_sleepEnabled: sleepEnabled.checked
    property alias cfg_lockScreenEnabled: lockScreenEnabled.checked
    property alias cfg_aboutThisComputerEnabled: aboutThisComputerEnabled.checked
    property alias cfg_aboutThisComputerSettings: aboutThisComputerSettings.text
    property alias cfg_systemPreferencesEnabled: systemPreferencesEnabled.checked
    property alias cfg_systemPreferencesSettings: systemPreferencesSettings.text
    property alias cfg_appStoreEnabled: appStoreEnabled.checked
    property alias cfg_appStoreSettings: appStoreSettings.text
    property alias cfg_forceQuitEnabled: forceQuitEnabled.checked
    property alias cfg_forceQuitSettings: forceQuitSettings.text
    property alias cfg_homeEnabled: homeEnabled.checked
    property alias cfg_homeSettings: homeSettings.text
    property alias cfg_editApplicationsEnabled: editApplicationsEnabled.checked

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        CheckBox {
            id: showFooter
            Kirigami.FormData.label: i18n("Show footer")
        }

        SpinBox {
            id: transparencyFooter
            from: 1
            to: 100
            Kirigami.FormData.label: i18n("Background opacity, %:")
        }

        Item {
			Kirigami.FormData.isSection: true
			Kirigami.FormData.label: i18n("Footer Actions")
		}
        QQC2.Label {
            QtLayouts.Layout.fillWidth: true
            QtLayouts.Layout.leftMargin: Kirigami.Units.largeSpacing * 2
            QtLayouts.Layout.rightMargin: Kirigami.Units.largeSpacing * 2
            text: i18n(
                "Select action buttons you want to see in menu footer."
            )
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
            visible: indicatorType.currentIndex == 0
        }

        ColumnLayout {
            RowLayout {
                CheckBox {
                    id: shutDownEnabled
                    text: i18n("Shut Down")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        shutDownSettings.enabled = checked;
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: rebootEnabled
                    text: i18n("Reboot")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        rebootSettings.enabled = checked;
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: logOutEnabled
                    text: i18n("Log Out")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        logOutSettings.enabled = checked;
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: sleepEnabled
                    text: i18n("Hibernate")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        sleepSettings.enabled = checked;
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: lockScreenEnabled
                    text: i18n("Lock Screen")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        lockScreenSettings.enabled = checked;
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: homeEnabled
                    text: i18n("Home Directory")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        homeSettings.enabled = checked;
                    }
                }

                Kirigami.ActionTextField {
                    id: homeSettings
                    enabled: homeEnabled.checked
                    rightActions: QQC2.Action {
                        icon.name: "edit-clear"
                        enabled: homeSettings.text !== ""
                        text: i18nc("@action:button", "Reset command")
                        onTriggered: {
                            homeSettings.clear();
                            root.cfg_homeSettings = "";
                        }
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: appStoreEnabled
                    text: i18n("App Store")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        appStoreSettings.enabled = checked;
                    }
                }

                Kirigami.ActionTextField {
                    id: appStoreSettings
                    enabled: appStoreEnabled.checked
                    rightActions: QQC2.Action {
                        icon.name: "edit-clear"
                        enabled: appStoreSettings.text !== ""
                        text: i18nc("@action:button", "Reset command")
                        onTriggered: {
                            appStoreSettings.clear();
                            root.cfg_appStoreSettings = "";
                        }
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: systemPreferencesEnabled
                    text: i18n("System Preferences")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        systemPreferencesSettings.enabled = checked;
                    }
                }

                Kirigami.ActionTextField {
                    id: systemPreferencesSettings
                    enabled: systemPreferencesEnabled.checked
                    rightActions: QQC2.Action {
                        icon.name: "edit-clear"
                        enabled: systemPreferencesSettings.text !== ""
                        text: i18nc("@action:button", "Reset command")
                        onTriggered: {
                            systemPreferencesSettings.clear();
                            root.cfg_systemPreferencesSettings = "";
                        }
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: aboutThisComputerEnabled
                    text: i18n("About This PC")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        aboutThisComputerSettings.enabled = checked;
                    }
                }

                Kirigami.ActionTextField {
                    id: aboutThisComputerSettings
                    enabled: aboutThisComputerEnabled.checked
                    rightActions: QQC2.Action {
                        icon.name: "edit-clear"
                        enabled: aboutThisComputerSettings.text !== ""
                        text: i18nc("@action:button", "Reset command")
                        onTriggered: {
                            aboutThisComputerSettings.clear();
                            root.cfg_aboutThisComputerSettings = "";
                        }
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: forceQuitEnabled
                    text: i18n("Force Quit App")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        forceQuitSettings.enabled = checked;
                    }
                }

                Kirigami.ActionTextField {
                    id: forceQuitSettings
                    enabled: forceQuitEnabled.checked
                    rightActions: QQC2.Action {
                        icon.name: "edit-clear"
                        enabled: forceQuitSettings.text !== ""
                        text: i18nc("@action:button", "Reset command")
                        onTriggered: {
                            forceQuitSettings.clear();
                            root.cfg_forceQuitSettings = "";
                        }
                    }
                }
            }

            RowLayout {
                CheckBox {
                    id: editApplicationsEnabled
                    text: i18n("Edit Applications")
                    checked: showAdvancedMode.checked
                    onCheckedChanged: {
                        editApplicationsSettings.enabled = checked;
                    }
                }
            }
        }
    }
}
