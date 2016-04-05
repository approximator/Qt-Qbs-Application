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
import time
from easyprocess import EasyProcess
from pyvirtualdisplay.smartdisplay import SmartDisplay


class WinDisplay:

    def waitgrab(self):
        import pyscreenshot
        return pyscreenshot.grab()


def take_screenshot(disp, file_name, timeout, out_file):
    file_name = os.path.normpath(os.path.abspath(file_name))
    if sys.platform.startswith('win'):
        file_name = '\\\\'.join(file_name.split('\\'))

    print('Starting {}'.format(file_name))
    with EasyProcess(file_name):
        print('Wait for {} sec.'.format(timeout))
        time.sleep(timeout)

        print('Taking screenshot')
        img = disp.waitgrab()
        img.save(out_file)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', required=True, help='Path to an application')
    parser.add_argument('-o', '--output', required=True, help='Output screenshot file')
    parser.add_argument('-t',
                        '--timeout',
                        required=False,
                        type=int,
                        default=20,
                        help='Timeout (seconds)')
    args = parser.parse_args()

    input_file_name = os.path.normpath(os.path.abspath(args.file))
    output_file_name = os.path.normpath(os.path.abspath(args.output))

    if sys.platform.startswith('win'):
        take_screenshot(WinDisplay(), input_file_name, args.timeout, output_file_name)
    else:
        with SmartDisplay(visible=0, size=(1024, 768), bgcolor='black') as disp:
            take_screenshot(disp, input_file_name, args.timeout, output_file_name)
