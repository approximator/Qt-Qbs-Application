/*
 * Copyright © 2015-2016 Andrii Shelest. All rights reserved.
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

var FileInfo = loadExtension("qbs.FileInfo");

function getRelativePath(from, to) {
    var fromAbsPath = FileInfo.joinPaths("/", from)
    var toAbsPath = FileInfo.joinPaths("/", to)
    return FileInfo.relativePath(fromAbsPath, toAbsPath)
}

function DirFilter() {
    this.allDirs = 0x400;
    this.dirs = 0x001;
    this.files = 0x002;
    this.drives = 0x004;
    this.noDot =  0x2000;
    this.noDotDot =  0x4000;
}

DirFilter.prototype.allEntries = function() {
    var result = this.dirs
        | this.files
        | this.noDotAndDotDot
        | this.drives
        | this.noDot
        | this.noDotDot;

    return result;
}

DirFilter.prototype.onlyDirs = function() {
    var result = this.dirs
        | this.drives
        | this.noDot
        | this.noDotDot;

    return result;
}

DirFilter.prototype.onlyFiles = function() {
    var result = this.dirs
        | this.files
        | this.noDot
        | this.noDotDot;

    return result;
}

function QmlModules(modulesPaths, qmlFiles, targetDirectory) {
    this.found = false;
    this.modulesPaths = modulesPaths;
    this.qmlFiles = modulesPaths;
    this.installDir = targetDirectory;
    this.dirFilter = new DirFilter();
}

QmlModules.prototype.copyModules = function() {
    if (this.modulesPaths) {
        this.qmlFiles = [];
        for (var i in this.modulesPaths) {
            if (!File.exists(this.modulesPaths[i]))
                throw("[QmlModuleProbe] Invalid Qml module dir: " + this.modulesPaths[i]);

            this.copyModule(this.modulesPaths[i]);
        }
    }
}

QmlModules.prototype.copyModule = function(moduleDir) {
    var moduleFiles = File.directoryEntries(moduleDir, this.dirFilter.allEntries());
    var inputPath;
    var outputPath;

    for (var i in moduleFiles) {
        inputPath = FileInfo.joinPaths(moduleDir, moduleFiles[i]);
        outputPath = FileInfo.joinPaths(this.installDir, moduleFiles[i]);

        File.copy(inputPath, outputPath);

        /* Recursive search for qml module files into each directory */
        this.searchFiles(moduleDir, moduleFiles[i]);
    }
}

/* Returns true if @file is not a directory */
QmlModules.prototype.searchFiles = function(dir, file) {
    var filePath = FileInfo.joinPaths(dir, file);
    var files = File.directoryEntries(filePath, this.dirFilter.onlyFiles());
    var dirs = File.directoryEntries(filePath, this.dirFilter.onlyDirs());

    for (var i in files)
        this.qmlFiles.push(FileInfo.joinPaths(filePath, files[i]))

    for (var i in dirs)
        this.searchFiles(filePath, dirs[i])

}
