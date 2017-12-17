/*
* Copyright © 2014-2016 Andrii Shelest. All rights reserved.
* Author: Andrii Shelest
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import QtQuick 2.0

Item {
    id: mbButtom
    width: 24
    height: 24

    property bool menu: true
    property int animationDuration: 350

    property color color: "white"
    readonly property real _lineHeight: height / 7
    signal menuClicked()
    signal backClicked()

    Column{
        id: _iconLayout
        anchors.fill: parent
        anchors.topMargin: _lineHeight
        anchors.bottomMargin: _lineHeight

        spacing: _lineHeight
        Repeater{
            id: _linesRepeater
            model: 3
            delegate:
                Rectangle {
                property real translateX: 0
                property real translateY: 0
                color: mbButtom.color
                width: mbButtom.width
                height: mbButtom._lineHeight
                antialiasing: true
                transform: Translate {x:translateX;y:translateY}
            }
        }
    }

    state: "menu"
    states: [
        State {
            name: "menu"
            when: menu
        },

        State {
            name: "back"
            when: !menu
            PropertyChanges {
                target: mbButtom; rotation: 180
            }

            PropertyChanges {
                target: _linesRepeater.itemAt(0);
                rotation: 45;
                width: ((mbButtom.height / 2)/Math.sin(45));
                translateX: (mbButtom.height / 2)-_lineHeight/2;
                translateY:(mbButtom._lineHeight / 1.41)
            }

            PropertyChanges {
                target: _linesRepeater.itemAt(1);
                translateX: -_lineHeight/2;
            }

            PropertyChanges {
                target: _linesRepeater.itemAt(2);
                rotation: -45;
                width:((mbButtom.height / 2)/Math.sin(45));
                translateX: (mbButtom.height / 2)-_lineHeight/2;
                translateY:-(mbButtom._lineHeight / 1.41)
            }
        }
    ]

    transitions: [
        Transition {
            RotationAnimation {
                target: mbButtom;
                direction: RotationAnimation.Clockwise;
                duration: animationDuration; easing.type: Easing.InOutQuad
            }

            PropertyAnimation {
                targets: [ _linesRepeater.itemAt(0), _linesRepeater.itemAt(1), _linesRepeater.itemAt(2) ];
                properties: "rotation, width, translateX, translateY";
                duration: animationDuration; easing.type: Easing.InOutQuad
            }
        }
    ]

    MouseArea {
        id: ink

        anchors.fill: parent
        enabled: mbButtom.enabled

        onClicked: {
            if (menu)
                menuClicked()
            else
                backClicked();
        }
    }

}
