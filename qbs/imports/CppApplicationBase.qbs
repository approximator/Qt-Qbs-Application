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
        cpp.systemIncludePaths: [
            // todo: find out a way better than qbs.getEnv('QTDIR')
            FileInfo.joinPaths(qbs.getEnv('QTDIR'), 'include'),
            FileInfo.joinPaths(qbs.getEnv('QTDIR'), 'include/QtCore'),
            FileInfo.joinPaths(qbs.getEnv('QTDIR'), 'include/QtGui'),
            FileInfo.joinPaths(qbs.getEnv('QTDIR'), 'include/QtQml'),
        ]
    }

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
}
