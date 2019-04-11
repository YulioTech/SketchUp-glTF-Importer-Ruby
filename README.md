---
title: Yulio SketchUp glTF Importer (in Ruby)
tags: SketchUp, glTF, importer, plug-in, 3D geometry
author: Yulio Technolgies Inc.
status: discontinued development
---

## Yulio SketchUp glTF Importer

Yulio SketchUp glTF Importer is a Ruby based SketchUp plug-in that adds the ability to import arbitrary 3D scenes into SketchUp from the glTF 2.0 format. Both the embedded glTF (.gltf file extension) and binary glTF (.glb file extension) are supported. The plug-in development was abandoned due to the inherent performance limitations of the SketchUp Ruby API implementation - it seems that the importer processing times scale exponentially with the increase in the amount of imported geometry.

### Original Authors
This project builds of top of the work done by David R White and Y C White, who were the initiators and original creators of the free-to-use [Khronos glTF importer](https://extensions.sketchup.com/en/content/gltf-import) and [Khronos glTF exporter](https://extensions.sketchup.com/en/content/gltf-exporter) plug-ins. The initial release is a carbon copy of their earlier Ruby based version of the importer plug-in with no additions or modification, other than the renaming of the source files and modules, and the addition of the MIT license.

### Compilation, Installation and Usage 
To install the plug-in, copy the 'yulio_gltf_import.rb' files and the 'yulio_gltf_import' folder to the '%userprofile%\AppData\Roaming\SketchUp\SketchUp 2018\SketchUp\Plugins'. Your path may differ according to the installed SketchUp version. The plug-in was tested on the SketchUp 2017 Pro and SketchUp 2018 Pro (earlier versions might work, but are not guaranteed to do so).

Once installed, the import option for glTF will be available in SketchUp under 'File -> Import', along with the other native import types.

### Authors

* [Yulio R&D Team](https://github.com/YulioTech)
