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

module Yulio
	module GltfImporter
		
		class GltfMesh
			def initialize(name, primitive_array)
				@primitive_array = primitive_array
				@name = name
			end
			
			def get_name()
				return @name
			end
			
			def get_primitives()
				return @primitive_array
			end
			
			def self.get_meshes(json, meshes)
				json["meshes"].each { |mesh|
					#puts "import mesh"
					name = mesh["name"]
					
					primitive_array = []
					primitives = mesh["primitives"]
					if primitives != nil
						primitives.each { |primitive|
							#puts "import primitive"
							attributes = primitive["attributes"]
							position = attributes["POSITION"]
							normal = attributes["NORMAL"]
							texcoord = attributes["TEXCOORD_0"]
							color = attributes["COLOR_0"]
							indices = primitive["indices"]
							mode = primitive["mode"]
							material = primitive["material"]
							
							if mode == nil
								mode = 4
							end
							#puts "position:" + position.to_s + " normal:" + normal.to_s + " texcoord:"+ texcoord.to_s + " indices:" + indices.to_s + " mode:" + mode.to_s + " material:" + material.to_s
							if mode == 4
								p = GltfMeshPrimitive.new(position, normal, texcoord, indices, mode, material, color)
								primitive_array.push(p)
							end
						}
					end
					m = GltfMesh.new(name, primitive_array)
					meshes.push(m)
					
				}
			end
		end
		
		class GltfMeshPrimitive
			def initialize(position, normal, texcoord, indices, mode, material, color)
				@position = position
				@normal = normal
				@texcoord = texcoord
				@indices = indices
				@mode = mode	#not used, assumed to be 4 (triangles)
				@material = material
				@color = color
			end
			
			def get_position
				return @position
			end
			def get_normal
				return @normal
			end
			def get_texcoord
				return @texcoord
			end
			def get_indices
				return @indices
			end
			def get_material
				return @material
			end
			def get_color
				return @color
			end
		end
	end
end
