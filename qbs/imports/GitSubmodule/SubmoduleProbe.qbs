import qbs 1.0
import qbs.FileInfo

import "gitFunctions.js" as Util

Probe {
    // Inputs
    property path gitRootDir: sourceDirectory
    property path moduleName
    property path moduleSrcDir: FileInfo.joinPaths(sourceDirectory, moduleName)

    configure: {
        if (!moduleName)
            throw('"moduleName" must be specified');
        found = Util.loadModule(moduleName, moduleSrcDir, gitRootDir);
    }
}
