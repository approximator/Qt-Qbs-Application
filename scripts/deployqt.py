#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright © 2016 Oleksii Aliakin. All rights reserverd.
# Author: Oleksii Aliakin (alex@nls.la)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import sys
import subprocess
import shutil
from glob import glob


def get_exe_full_path(exe_file):
    path, name = os.path.split(exe_file)
    if path and os.path.isfile(exe_file):
        return exe_file

    for path in os.environ['PATH'].split(os.pathsep):
        full_exe_file_name = os.path.join(path.strip('" '), exe_file)
        if os.path.isfile(full_exe_file_name):
            return full_exe_file_name

    return None


class QtDeployer():

    def __init__(self, executable, install_dir, data_dir, libraries_dir, qmake, debug_build, libs,
                 qt_plugins, qml):
        self.fgap_exe_file = os.path.normpath(executable)
        self.install_dir = os.path.normpath(install_dir)
        self.data_dir = os.path.normpath(data_dir)
        self.libraries_dir = os.path.normpath(libraries_dir)
        self.qmake = os.path.normpath(qmake)
        self.debug_build = False
        self.needed_libraries = libs
        self.plugins = qt_plugins
        self.needed_qml = qml
        if debug_build == "Debug":
            self.debug_build = True

        p = subprocess.Popen([self.qmake, '-query', 'QT_INSTALL_LIBS'], stdout=subprocess.PIPE)
        self.qt_libs_dir, err = p.communicate()
        self.qt_libs_dir = os.path.normpath(self.qt_libs_dir.rstrip().decode('utf-8'))
        p = subprocess.Popen([self.qmake, '-query', 'QT_INSTALL_BINS'], stdout=subprocess.PIPE)
        self.qt_bin_dir, err = p.communicate()
        self.qt_bin_dir = os.path.normpath(self.qt_bin_dir.rstrip().decode('utf-8'))
        p = subprocess.Popen([self.qmake, '-query', 'QT_INSTALL_PLUGINS'], stdout=subprocess.PIPE)
        self.qt_plugins_dir, err = p.communicate()
        self.qt_plugins_dir = os.path.normpath(self.qt_plugins_dir.rstrip().decode('utf-8'))
        p = subprocess.Popen([self.qmake, '-query', 'QT_INSTALL_QML'], stdout=subprocess.PIPE)
        self.qt_qml_dir, err = p.communicate()
        self.qt_qml_dir = os.path.normpath(self.qt_qml_dir.rstrip().decode('utf-8'))

        self.chrpath = get_exe_full_path('patchelf')
        if not self.chrpath:
            print('Can not find patchelf\nInstall by: sudo apt-get install patchelf')
            raise Exception('Error happened while changing rpath')

        print('Qt deployer starting...')
        print('executable:\t{}'.format(self.fgap_exe_file))
        print('Install dir:\t{}'.format(self.install_dir))
        print('Data dir:\t{}'.format(self.data_dir))
        print('Libraries dir:\t{}'.format(self.libraries_dir))
        print('qmake:\t{}'.format(self.qmake))
        print('Debug build:\t{}'.format(self.debug_build))
        print('Qt libs dir:\t{}'.format(self.qt_libs_dir))
        print('Qt bin dir:\t{}'.format(self.qt_bin_dir))
        print('Qt plugins dir:\t{}'.format(self.qt_plugins_dir))
        print('Qt qml dir:\t{}'.format(self.qt_qml_dir))

    def is_executable(self, path):
        return '.so' in path  # TODO: find more reliable way to determine if file is a shared library

    def change_rpath(self, filename, new_rpath):
        rpath = '$ORIGIN/' + new_rpath
        if new_rpath == '.':
            rpath = '$ORIGIN'
        command = [self.chrpath, '--set-rpath', rpath, filename]
        print(' '.join(command))
        try:
            subprocess.check_call(command)
        except:
            print('Failed to change rpath: {}'.format(filename))
            return False
        return True

    def get_dependencies(self, file_name, dependencies):
        try:
            p = subprocess.Popen(
                [file_name],
                stdout=subprocess.PIPE,
                env=dict(os.environ.copy(), LD_TRACE_LOADED_OBJECTS='1'))
            deps, err = p.communicate()
        except OSError:
            return

        for lib in deps.split('\n'):
            lib_name = ''
            lib_dir = ''
            lib_name_and_dir = lib.split('=>')
            if len(lib_name_and_dir) > 1:
                lib_name = lib_name_and_dir[0].strip()
                lib_dir = lib_name_and_dir[1].strip()
                lib_dir = lib_dir[0:lib_dir.find('(')].strip()
            if lib_name and lib_dir:
                self.get_dependencies(lib_dir, dependencies)

                dependencies[lib_name] = lib_dir

    def resolve_libraries_paths(self, libs, directories):
        lib_ext = '*.so.*'
        resolved_libs = set()
        for needed_lib in libs:
            for dir in directories:
                resolved_libs = resolved_libs.union(set(glob(os.path.join(dir, needed_lib +
                                                                          lib_ext))))
        return resolved_libs

    def copy_libs(self, libs):
        print('copying Qt libraries...')

        dest = self.libraries_dir
        symlinks = []

        for lib in libs:
            if os.path.islink(lib):
                symlinks.append((os.readlink(lib), os.path.join(dest, os.path.basename(lib))))
            else:
                if not os.path.exists(dest):
                    os.makedirs(dest)
                copy_to = os.path.join(dest, os.path.basename(lib))
                print('Copying {} -> {}'.format(lib, copy_to))
                shutil.copy2(lib, copy_to)
                if self.is_executable(copy_to):
                    self.change_rpath(copy_to, os.path.relpath(dest, self.libraries_dir))
        # making symlinks after all the libs were copied
        for symlink in symlinks:
            try:
                print('Make link {} -> {}'.format(
                    os.path.basename(symlink[1]), os.path.basename(symlink[0])))
                os.symlink(symlink[0], symlink[1])
            except:
                print('Error while creating the links {} -> {}'.format(
                    os.path.basename(symlink[0]), symlink[1]))

    # def copy_libs(self, libs):
    #     print('copying Qt libraries...')
    #     dest = self.libraries_dir
    #
    #     for lib in libs:
    #         lib_real_path = lib
    #         while os.path.islink(lib_real_path):
    #             lib_real_path = os.path.realpath(
    #                 os.path.join(os.path.dirname(lib_real_path), os.readlink(lib_real_path)))
    #
    #         if not os.path.exists(dest):
    #             os.makedirs(dest)
    #
    #         copy_to = os.path.join(dest, os.path.basename(lib))
    #         print('Copying {} -> {}'.format(lib_real_path, copy_to))
    #         shutil.copy2(lib_real_path, copy_to)
    #         if self.is_executable(copy_to):
    #             self.change_rpath(copy_to, os.path.relpath(dest, self.libraries_dir))

    def copy_plugins(self):
        print('Copying plugins: {}'.format(self.plugins))
        for plugin in self.plugins:
            target = os.path.join(self.data_dir, 'plugins', plugin)
            if os.path.exists(target):
                shutil.rmtree(target)
            plugin_path = os.path.join(self.qt_plugins_dir, plugin)
            if os.path.exists(plugin_path):
                self.copytree(plugin_path, target, symlinks=True)
            else:
                print('Can not copy {} to {}'.format(plugin_path, target))

    def copy_qml(self):
        if os.path.exists(self.qt_qml_dir):
            print('Copying qt quick 2 imports')
            target = os.path.join(self.data_dir, 'qml')

            qmls = glob(self.qt_qml_dir + '/*')
            for lib in filter(lambda x: os.path.basename(x) in self.needed_qml, qmls):
                self.copytree(lib, os.path.join(target, os.path.basename(lib)), symlinks=True)
        else:
            print('Error {} does not exist.'.format(self.qt_qml_dir))

    def deploy(self):
        changed = self.change_rpath(
            self.fgap_exe_file,
            os.path.relpath(self.libraries_dir, os.path.dirname(self.fgap_exe_file)))
        if not changed:
            raise Exception('Error happened while changing rpath')

        libs = self.resolve_libraries_paths(
            map(lambda lib: 'lib' + lib, self.needed_libraries),
            [self.qt_libs_dir, '/usr/lib', '/usr/lib/x86_64-linux-gnu'])
        # deps = {}
        # self.get_dependencies(self.fgap_exe_file, deps)

        self.copy_libs(libs)
        self.copy_plugins()
        self.copy_qml()

    def copytree(self, src, dst, symlinks=False, ignore=None):
        if not os.path.exists(dst):
            os.makedirs(dst)
        for item in os.listdir(src):
            s = os.path.join(src, item)
            d = os.path.join(dst, item)
            if os.path.isdir(s):
                self.copytree(s, d, symlinks, ignore)
            else:
                shutil.copy2(s, d)
                if self.is_executable(d):
                    self.change_rpath(d, os.path.relpath(self.libraries_dir, os.path.dirname(d)))


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--app-file',
                        required=True,
                        help='Path to the application that is being deployed')
    parser.add_argument('--install-dir', required=False)
    parser.add_argument('--data-dir', required=False)
    parser.add_argument('--libraries-dir', required=False)
    parser.add_argument('--qmake', required=True)
    parser.add_argument('--debug-build', required=True, help='"debug" or "release"')
    parser.add_argument('--libs', required=True, type=str, nargs='+')
    parser.add_argument('--qt-plugins', required=True, type=str, nargs='+')
    parser.add_argument('--qml', required=True, type=str, nargs='+')
    args = parser.parse_args()

    args.app_file = os.path.normpath(args.app_file)

    # set default values for the not specified parameters
    if not args.install_dir:
        args.install_dir = os.path.dirname(args.app_file)
    if not args.data_dir:
        args.data_dir = os.path.join(args.install_dir, 'data')
    if not args.libraries_dir:
        args.libraries_dir = os.path.join(args.data_dir, 'lib')

    deployer = QtDeployer(executable=os.path.normpath(args.app_file),
                          install_dir=args.install_dir,
                          data_dir=args.data_dir,
                          libraries_dir=args.libraries_dir,
                          qmake=args.qmake,
                          debug_build=args.debug_build,
                          libs=args.libs,
                          qt_plugins=args.qt_plugins,
                          qml=args.qml)
    deployer.deploy()
    return 0


if __name__ == "__main__":
    result = main()
    sys.exit(result)
