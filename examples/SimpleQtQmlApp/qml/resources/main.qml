import QtQuick 2.5
import QtQuick.Window 2.2

import Simple 1.0
import Simple.Tools 1.0

Window {
    visible: true
    color: "blue"

    FpsItem {
        id: fpsItem
        anchors.fill: parent
    }

    AnimatedRect {
        anchors.centerIn: parent
        width: parent.width / 2
        height: width
    }

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

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        color: "white"
        text: "fps: %1".arg(fpsItem.fps)
    }
}
