import QtQuick 2.5
import QtQuick.Window 2.2
import Simple 0.1

Window {
    visible: true
    color: "blue"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Qt.quit();
        }
    }

    MenuBackButton {
        anchors.centerIn: parent
        onMenuClicked: menu = false
        onBackClicked: menu = true
    }
}
