#-----------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2019 Yulio Technologies Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#-----------------------------------------------------------------------------------

Sketchup.require 'sketchup'
Sketchup.require 'extensions'

# 1.1.0 Added support for 8-bit indices, was previously supporting 32-bit and 16-bit indicies
# 1.2.0 Added support for material extensions, KHR_materials_pbrSpecularGlossiness, used by SketchFab glTF exports.
#       Fixed quaternion rotation axis
#       Add diffuse colour from KHR_materials_pbrSpecularGlossiness
# 1.2.1 Fixed alpha transparency loading issue
# 1.2.2 Emissive text exists in some files instead of Diffuse texture, use that if diffuse not found
#       Fix colour in PBR

module Yulio
	module GltfImporter
		unless file_loaded?(__FILE__)
			# because LanguageHandler.new works at this directory level, create a constant for it here
			TRANSLATE = LanguageHandler.new('yulio_gltf_import.strings')
			
			ex = SketchupExtension.new(TRANSLATE["title"], 'yulio_gltf_import/gltf_import')
			ex.description = TRANSLATE["description"]
			ex.version     = '1.0.0'
			ex.copyright   = '©2019'
			ex.creator     = 'Yulio Technologies Inc.'
			Sketchup.register_extension(ex, true)
			file_loaded(__FILE__)
		end
	end
end
