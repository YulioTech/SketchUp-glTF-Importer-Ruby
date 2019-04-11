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

Sketchup.require 'yulio_gltf_import/gltf_buffer_view'

module Yulio
	module GltfImporter
		
		class GltfAccessor
			# an accessor gets a byte array, int array, uv array, or xyz array from the buffer view
			GL_BYTE = 5120
			GL_UNSIGNED_BYTE = 5121
			GL_UNSIGNED_SHORT = 5123
			GL_UNSIGNED_INT = 5125
			GL_FLOAT = 5126
			
			def initialize(buffer_view, buffer_view_index, byte_offset, count, component_type, type, accessor_number)

				
				
				@accessor_number = accessor_number
				@data = nil
				@buffer_view = buffer_view
				@buffer_view_index = buffer_view_index
				@byte_offset = byte_offset
				@count = count
				@component_type = component_type	# 5126 = float, 5123 = ushort, 5125 = uint 
				@component_type_size = 1
				if @component_type == GL_UNSIGNED_SHORT
					@component_type_size = 2
				end
				if @component_type == GL_FLOAT || @component_type == GL_UNSIGNED_INT
					@component_type_size = 4
				end
				#@max = max
				#@min = min
				@type = type	# SCALAR, VEC2, VEC3, VEC4, MAT2, MAT3, MAT4
				@type_size = 1
				if @type == 'VEC2'
					@type_size = 2
				end
				if @type == 'VEC3'
					@type_size = 3
				end
				if @type == 'VEC4'
					@type_size = 4
				end
				if @type == 'MAT2'
					@type_size = 4
				end
				if @type == 'MAT3'
					@type_size = 9
				end
				if @type == 'MAT4'
					@type_size = 16
				end
				#puts 'Created accessor. Buffer view: ' + buffer_view_index.to_s + ' offset:' + byte_offset.to_s + ' for type ' + @type + " componentType:" + component_type.to_s
			end
			
			def get_indices()
				if @data != nil
					return @data
				end
				#puts "get_indices: " + @buffer_view_index.to_s + ' component type: ' + @component_type.to_s + ' size: ' + @component_type_size.to_s
				
				if @type != 'SCALAR'
					puts 'Error'
				end
				cb = @component_type_size * @count
				buf = @buffer_view.get_bytes(@byte_offset, cb)
				if @component_type == GL_UNSIGNED_BYTE
					#puts 'unpacking 8-bit array'
					values = buf.unpack("C*")
					@data = values
					return values
				end
				if @component_type == GL_UNSIGNED_SHORT
					#puts 'unpacking 16-bit array'
					values = buf.unpack("v*")
					#i = 0
					#while i < 10
					#	puts i.to_s + ' ' + values[i].to_s
					#	i=i+1
					#end
					@data = values
					return values
				end
				if @component_type == GL_UNSIGNED_INT
					#puts 'unpacking 32-bit array'
					values = buf.unpack("V*")
					@data = values
					return values
				end
				return nil
			end
			
			def get_floats()
				cb = @component_type_size * @type_size * @count
				#puts 'Accessor:' + @accessor_number.to_s + ' cb:' + cb.to_s
				buf = @buffer_view.get_bytes(@byte_offset, cb)
				values = buf.unpack("e*")
				return values
			end
			
			def get_colors()
				if @data != nil
					return @data
				end
				
				#puts @type
				#puts @component_type
					
				if @type == 'VEC3'
					if @component_type == GL_FLOAT
						vec4 = []
						floats = get_floats()
						i = 0
						while(i < floats.length)
							r = floats[i]
							g = floats[i+1]
							b = floats[i+2]
							vec4.push([r,g,b,1.0])
							i = i + 3
						end
						@data = vec4
						return vec4
					end
				end
				
				if @type == 'VEC4'
					if @component_type == GL_FLOAT
						vec4 = []
						floats = get_floats()
						i = 0
						while(i < floats.length)
							r = floats[i]
							g = floats[i+1]
							b = floats[i+2]
							a = floats[i+3]
							vec4.push([r,g,b,a])
							i = i + 4
						end
						@data = vec4
						return vec4
					end
					if @component_type == GL_UNSIGNED_BYTE
						vec4 = []
						values = buf.unpack("C*")
						i = 0
						while(i < floats.length)
							r = values[i] / 255.0
							g = values[i+1] / 255.0
							b = values[i+2] / 255.0
							a = values[i+3] / 255.0
							vec4.push([r,g,b,a])
							i = i + 4
						end
						@data = vec4
						return vec4
					end
				end
			end
			
			
			def get_vector2()
				if @data != nil
					return @data
				end
				#puts @type
				if @type != 'VEC2'
					puts 'Error'
				end
				vec2 = []
				floats = get_floats()
				i = 0
				while(i < floats.length)
					u = floats[i]
					v = floats[i+1]
					vec2.push([u,v])
					i = i + 2
				end
				@data = vec2
				return vec2
			end
			
			def get_vector3()
				if @data != nil
					return @data
				end
				#puts @type
				if @type != 'VEC3'
					puts 'Error'
				end
				vec3 = []
				floats = get_floats()
				i = 0
				while(i < floats.length)
					x = floats[i]
					y = floats[i+1]
					z = floats[i+2]
					vec3.push([x,y,z])
					i = i + 3
				end
				@data = vec3
				return vec3
			end
			
			def self.get_accessors(json, buffer_views, accessors)
				acc = json["accessors"]
				acc.each { |accessor|
					buffer_view_index = accessor["bufferView"]
					if buffer_view_index == nil
						buffer_view_index = 0
					end
					bv = buffer_views[buffer_view_index]
					byte_offset = accessor["byteOffset"]
					if byte_offset == nil
						byte_offset = 0
					end
					component_type = accessor["componentType"]
					count = accessor["count"]
					type = accessor["type"]
					#max = accessor["max"]
					#min = accessor["min"]
					if bv == nil
						puts "ERROR: INVALID BUFFER VIEW"
					end
					a = GltfAccessor.new(bv, buffer_view_index, byte_offset, count, component_type, type, accessors.length)
					accessors.push(a)
				}
			end
		end
	end
end
