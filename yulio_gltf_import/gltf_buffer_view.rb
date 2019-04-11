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

module Yulio
	module GltfImporter

		class GltfBufferView
			# a buffer view is an offset and range into a buffer
			def initialize(buffer, bufferIndex, byte_offset, byte_length, target, byte_stride, buffer_view_number)
				@buffer_view_number = buffer_view_number
				@buffer = buffer
				if(byte_offset == nil)
					@byte_offset = 0
				else
					@byte_offset = byte_offset
				end
				
				@byte_length = byte_length
				
				if(target == nil)
					@target = 0
				else
					@target = target
				end
				
				if(@byte_stride == nil)
					@byte_stride = 1
				else
					@byte_stride = byte_stride
				end
				#puts 'Created bufferView buffer:' + bufferIndex.to_s + ' byteOffset:' + @byte_offset.to_s + ' byteLength:' + @byte_length.to_s + ' target:' + @target.to_s + ' byteStride:' + @byte_stride.to_s
			end
			
			def get_bytes(offset, length)
				if length == -1
					length = @byte_length
				end
				i = offset + @byte_offset
				#puts 'accessing buffer view ' + @buffer_view_number.to_s + ' @' + offset.to_s + ' length:' + length.to_s + ' final offset: ' + i.to_s
				cb = length
				#if i + cb > @byte_length
				#	puts "invalid offset into buffer: " + i.to_s + ' ' + cb.to_s + ' '  + @byte_length.to_s
				#end
				return @buffer.get_bytes(i,cb)
			end
			
			def self.read_buffer_views(json, buffers, buffer_views)
				json["bufferViews"].each { |buffer_view|
					bufferIndex = buffer_view["buffer"]
					buffer = buffers[bufferIndex]
					byte_offset = buffer_view["byteOffset"]
					byte_length = buffer_view["byteLength"]
					target = buffer_view["target"]
					byte_stride = buffer_view["byteStride"]
					bv = GltfBufferView.new(buffer, bufferIndex, byte_offset, byte_length, target, byte_stride, buffer_views.length)
					buffer_views.push(bv)
				}
			end
			
		end
	end
end
