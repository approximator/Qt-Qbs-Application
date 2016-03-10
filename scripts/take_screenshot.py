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
import time
from subprocess import Popen
import pyscreenshot as ImageGrab


def get_exe_full_path(exe_file):
    path, name = os.path.split(exe_file)
    if path and os.path.isfile(exe_file):
        return exe_file

    for path in os.environ['PATH'].split(os.pathsep):
        full_exe_file_name = os.path.join(path.strip('" '), exe_file)
        if os.path.isfile(full_exe_file_name):
            return full_exe_file_name

    return None


def take_screenshot(out_file):
    image = ImageGrab.grab()

    if len(out_file.split('.')) < 2:
        out_file += '.png'

    print(out_file)
    image.save(out_file)
    print('Screenshot saved to: {}'.format(out_file))


class Xvfb:
    def __init__(self, xvfb_file):
        self.display = ':5'
        self.screen = '1280x1024x24'
        self.xvfb_executable = get_exe_full_path(xvfb_file)

        if not self.xvfb_executable:
            raise Exception('Sorry, can not find Xvfb executable to start')

        self.process = None

    def start(self):
        xvfb_args = [self.xvfb_executable, self.display, '-screen 0 {}'.format(self.screen)]
        print('Starting: {}'.format(' '.join(xvfb_args)))
        self.process = Popen(xvfb_args)

    def stop(self):
        if self.process:
            self.process.terminate()


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file',
                        required=True,
                        help='Path to an application')
    parser.add_argument('-o', '--output', required=True, help='Output screenshot file')
    parser.add_argument('-t', '--timeout', required=False, type=int, default=20, help='Timeout (seconds)')
    parser.add_argument('-x', '--xvfb', required=False, action='store_true', help='Start Xvfb')
    parser.add_argument('--xvfb-file', required=False, default='Xvfb', help='Xvfb file')
    args = parser.parse_args()

    if args.xvfb:
        xvfb = Xvfb(args.xvfb_file)
        xvfb.start()

    app = Popen(args.file)
    time.sleep(args.timeout)
    take_screenshot(args.output)
    app.terminate()
    if args.xvfb:
        xvfb.stop()
