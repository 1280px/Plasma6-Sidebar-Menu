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

Item {
    RowLayout {
        id: searchComponent
        width: rootItem.spaceWidth

        // Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        // Item {
        //     Layout.fillWidth: true
        // }

        PC3.TextField {
            id: searchField
            activeFocusOnTab: true
            visible: true
            Layout.fillWidth: true
            placeholderText: i18n("Start typing to search")
            topPadding: 6
            bottomPadding: 6
            focus: true
            leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.iconSizes.small
            text: ""
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1

            Kirigami.Icon {
                source: "search"
                height: Kirigami.Units.iconSizes.small
                width: height

                anchors {
                    left: searchField.left
                    verticalCenter: searchField.verticalCenter
                    leftMargin: Kirigami.Units.smallSpacing * 2
                }
            }

            onTextChanged: {
                runnerModel.query = text;
                kicker.searching = text == "" ? false : true;
            }

            Keys.onPressed: (event) => {
                kicker.keyIn = "Search: " + event.key;

                switch (event.key) {
                    case Qt.Key_Escape:
                        event.accepted = true;
                        // Close onl7 if search is already empty
                        if (kicker.searching) {
                            emptysearch();
                            rootItem.reset();
                        } else {
                            rootItem.turnclose();
                        }
                        break;
                    case Qt.Key_Backspace:
                        // Let TextField handle it natively
                        break;
                    case Qt.Key_Down:
                        event.accepted = true;
                        kicker.showFavorites
                            ? globalFavoritesGrid.tryActivate(0, 0)
                            : mainColumn.tryActivate(0, 0);
                        break;
                    case Qt.Key_Tab:
                    case Qt.Key_Backtab:
                    case Qt.Key_Up:
                    case Qt.Key_Enter:
                    case Qt.Key_Return:
                    default:
                        // Propagate naturally
                        break;
                }
            }

            function backspace() {
                if (!kicker.expanded) {
                    return;
                }

                focus = true;
                text = text.slice(0, -1);
                if (text == "" || searchField.text == "") {
                    searchField.text = "";
                }
            }

            function appendText(newText) {
                if (!kicker.expanded) {
                    return;
                }

                kicker.searching = true;
                focus = true;
                text = text + newText;
            }
        }

        PC3.ToolButton {
            id: btnFavorites
            icon.name: "favorites"
            visible: true // === false
            flat: !kicker.showFavorites
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Favorites")

            onClicked: {
                kicker.showFavorites = true;
                searchField.text = "";
                rootItem.reset();
            }
        }

        PC3.ToolButton {
            id: btnAllApps
            icon.name: "view-list-icons"
            flat: kicker.showFavorites
            visible: true // === false
            ToolTip.delay: 200
            ToolTip.timeout: 1000
            ToolTip.visible: hovered
            ToolTip.text: i18n("All apps")

            onClicked: {
                kicker.showFavorites = false;
                searchField.text = "";
                rootItem.reset();
            }
        }
    }

    function emptysearch() {
        searchField.text = "";
    }
    function backspace() {
        searchField.backspace();
    }
    function appendText(p) {
        searchField.appendText(p);
    }
    function gofocus() {
        searchField.focus = true;
        // searchField.forceActiveFocus();
    }
}
