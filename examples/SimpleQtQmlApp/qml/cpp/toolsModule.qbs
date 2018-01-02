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

QmlPlugin {
    name: "qml_simple_tools"
    moduleUri: "Simple.Tools"

    files: [
        "tools/*.h",
        "tools/*.cpp"
    ]

    Group {
        name: "qmldir_file"
        fileTags: ["qml_import"]
        files: ["tools/qmldir"]
    }
}