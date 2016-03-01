/*
 * Copyright © 2015-2016 Oleksii Aliakin. All rights reserved.
 * Author: Oleksii Aliakin (alex@nls.la)
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

Product {
    type: "application"

    property string cppVersion: "c++11"
    property bool extraWarnings: true

    Depends { name: "cpp" }
    cpp.cxxLanguageVersion: cppVersion
    cpp.warningLevel: "all"

    Properties {
        condition: qbs.targetOS.contains("linux") && extraWarnings
        cpp.commonCompilerFlags: ['-Wall', '-Wextra', '-pedantic', '-Weffc++', '-Wold-style-cast']
    }

    cpp.systemIncludePaths: [
        FileInfo.joinPaths(Qt.core.incPath),
        FileInfo.joinPaths(Qt.core.incPath, 'QtCore'),
        FileInfo.joinPaths(Qt.core.incPath, 'QtGui'),
        FileInfo.joinPaths(Qt.core.incPath, 'QtQml'),
        FileInfo.joinPaths(Qt.core.incPath, 'QtSvg'),
    ]

    cpp.rpaths: qbs.targetOS.contains("osx")
                ? ["@executable_path/../lib"]
                : ["$ORIGIN/../lib"]

    Properties {
        //OS X special compiler configs
        condition: qbs.targetOS.contains("osx")
        cpp.cxxStandardLibrary: "libc++"
    }

    Group {
        fileTagsFilter: "application"
        qbs.install: true
    }

    // Some debug output
    property string debug: {
        print("Cpp version: " + cpp.cxxLanguageVersion)
        print("System include paths:")
        cpp.systemIncludePaths.forEach(function(path) {
            print("    " + path);
        })

        print("Install to: " + qbs.installRoot)
    }
}
