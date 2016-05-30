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

import qbs
import qbs.FileInfo


Product {
    type: "copied_resource"

    Depends {name: "bundle"}
    Depends {name: "cpp"}

    property string sourcesLocation: sourceDirectory
    property string srcPrefix: "modules"
    property string targetDirectory: product.destinationDirectory

    Depends { name: "copyable_resource" }
    copyable_resource.prefix: srcPrefix
    copyable_resource.targetDirectory: targetDirectory
}
