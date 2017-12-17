/*
* Copyright © 2014-2017 Andrii Shelest. All rights reserved.
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

Rectangle {
    width: 100
    height: 100

    anchors.centerIn: parent

    ColorAnimation on color {
        from: "grey"
        to: "green"
        duration: 2000

        running: true
        loops: Animation.Infinite
    }

    RotationAnimation on rotation{
        from: 0
        to: 360
        duration: 2000

        running: true
        loops: Animation.Infinite
    }
}
