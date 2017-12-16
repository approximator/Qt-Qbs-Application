/*
 * Copyright © 2015-2017 Oleksii Aliakin. All rights reserved.
 * Author: Oleksii Aliakin (alex@nls.la)
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

import qbs
import qbs.FileInfo

Module {
    name: "app_config"

    property string binDir: ""
    property string dataDir: "data"
    property string qmlInstallDir: FileInfo.joinPaths(dataDir, "qml")
    property string configInstallDir: FileInfo.joinPaths(dataDir, "config")
    property string pluginsInstallDir: FileInfo.joinPaths(dataDir, "plugins")
    property string libsInstallDir: "lib"
    property string includesInstallDir: FileInfo.joinPaths(dataDir, "include")
}
