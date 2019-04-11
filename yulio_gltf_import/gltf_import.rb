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

require 'langhandler'
Sketchup.require 'yulio_gltf_import/gltf_importer'

# 2017-08-08 Added support for 8-bit indices

module Yulio
	module GltfImporter
		
		class GltfImportGltf < Sketchup::Importer
			def description
				return TRANSLATE["textGltf"]
			end
			def file_extension
				return "gltf"
			end
			def id
				return "com.sketchup.importers.yulio_gltf"
			end
			def supports_options?
				return false
			end
			def do_options
				#@scale = 100.0
				#my_settings = UI.inputbox(['Scale:'], [@scale],	"Import Options")
				#@scale = my_settings[0]
			end
			def load_file(file_path, status)
				importer = GltfImporter.new
				return importer.import(file_path)	# return 0 on successful import
			end
		end
		
		class GltfImportGlb < Sketchup::Importer
			def description
				return TRANSLATE["binaryGltf"]
			end
			def file_extension
				return "glb"
			end
			def id
				return "com.sketchup.importers.yulio_glb"
			end
			def supports_options?
				return false
			end
			def do_options
				#@scale = 100.0
				#my_settings = UI.inputbox(['Scale:'], [@scale],	"Import Options")
				#@scale = my_settings[0]
			end
			def load_file(file_path, status)
				importer = GltfImporter.new
				return importer.import(file_path)	# return 0 on successful import
			end
		end
		
		unless file_loaded?(__FILE__)
			Sketchup.register_importer(GltfImportGlb.new)
			Sketchup.register_importer(GltfImportGltf.new)
		end

	end
end

