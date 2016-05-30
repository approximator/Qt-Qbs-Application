var File = loadExtension("qbs.File");
var FileInfo = loadExtension("qbs.FileInfo");
var Process = loadExtension("qbs.Process");

function getModuleFiles(product, project) {
    var moduleName = product.moduleName;
    var moduleDir = product.moduleSrcDir;

    var gitOutput = gitSubmoduleExec(product.gitRootDir, moduleDir, "status");
    print("Status of submodule " + moduleName + "is: " + gitOutput);

    if (gitOutput[0] === '-') {
        gitOutput = gitSubmoduleExec(product.gitRootDir, moduleDir, "init");
        print("Initialize of submodule " + moduleName + ": " + gitOutput);

        gitOutput = gitSubmoduleExec(product.gitRootDir, moduleDir, "update");
        print("Updating of submodule " + moduleName + ": " + gitOutput);
    }

    // product.references = [FileInfo.joinPaths(moduleName, product.qbsReference)];
    // project.references = ["lib-qt-qml-tricks/src/QtLibrary.qbs"]
    return product.sourceFiles;
}

function loadModule(moduleName, moduleDir, gitRootDir) {
    var ret = true;

    var gitOutput = gitSubmoduleExec(gitRootDir, moduleDir, "status");
    print("Status of submodule " + moduleName + "is: " + gitOutput);

    if (gitOutput[0] === '-') {
        gitOutput = gitSubmoduleExec(gitRootDir, moduleDir, "init");
        print("Initialize of submodule " + moduleName + ": " + gitOutput);

        gitOutput = gitSubmoduleExec(gitRootDir, moduleDir, "update");
        print("Updating of submodule " + moduleName + ": " + gitOutput);
    }
    return ret;
}

function gitSubmoduleExec(workDir, moduleDir, cmd) {
    var process = new Process();
    var out_res = "";
    var cmd_args = ["submodule", cmd, moduleDir];

    process.setWorkingDirectory(workDir);
    process.exec("git", cmd_args, true);
    return process.readStdOut();
}
