/*
* Copyright © 2015-2016 Oleksii Aliakin. All rights reserved.
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
import QmlTools

QmlTools.QtQmlApplication
{
    name: "simpleQtQmlApp"
    appShortName: "qtQmlsimple"

    Depends { name: "Qt"; submodules: [ "qml", "quick" ] }

    qmlImportPaths: [
        FileInfo.joinPaths(project.appSourceRoot, "examples", "SimpleQtQmlApp", "imports")
    ]

    /* Main source file */
    Group {
        name: "main_source"
        files: [
            "main.cpp",
        ]
    }

    Group {
        name: "Resources"
        files: "qml.qrc"
    }

    /* Some debug output */
    property string debug: {
        print("Cpp version: " + cpp.cxxLanguageVersion)
        print("qmlImportPaths:")
        qmlImportPaths.forEach(function(path) {
            print("    " + path);
        })

        print("Install to: " + qbs.installRoot)
    }
}
