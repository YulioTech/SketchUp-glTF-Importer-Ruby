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

Sketchup.require 'yulio_gltf_import/gltf_buffer'
require "json"

module Yulio
	module GltfImporter
		class GltfFile
			def initialize()
			end
			
			def self.read(filename, buffers)
				ext = filename.split('.').last
				ext.downcase!
				
				if ext == 'gltf'
					json = IO.binread(filename)
					return JSON.parse(json)
				end
				
				# todo: retrieve length of file_length
				
				f = File.open(filename, "rb")
				header = f.read(4)
				# todo: verify header code
				
				version = f.read(4)
				
				v = version.unpack('V')[0]
				if v < 2.0 || v >= 3.0
					puts 'Cannot decode version ' + v.to_s + ' files'
					return nil
				end
				
				file_length = f.read(4)
				json_length = f.read(4)
				json_header = f.read(4)
				# todo: verify json header code
				
				cbFile = file_length.unpack('V')[0]
				cbJson = json_length.unpack('V')[0]
				
				json = f.read(cbJson)
				binary_length = f.read(4)
				binary_header = f.read(4)
				# todo: verify binary header code
				
				cb = binary_length.unpack('V')[0]
				
				binary = f.read(cb)
				
				f.close()
				
				buffer = GltfBuffer.new()
				buffer.add_bytes(binary)
				buffers.push(buffer)
				return JSON.parse(json)
			end
		end
	end
end
