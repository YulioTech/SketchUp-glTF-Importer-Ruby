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
		
		class GltfMaterial
			def initialize(name, texture_id,rgba, double_sided)
				@name = name
				@texture_id = texture_id
				@rgba = rgba
				@double_sided = double_sided
			end
			
			def get_texture_id()
				return @texture_id
			end
			
			def get_color()
				if @rgba == nil
					return [0.5,0.5,0.5,1.0]
				end
				return @rgba
			end
			
			def get_name()
				return @name
			end
			
			def is_double_sided()
				if @double_sided == nil
					return false
				end
				return @double_sided
			end
			
			def self.get_materials(json, materials)
				mats = json["materials"]
				if mats == nil
					return
				end
				mats.each { |material|
					name = material["name"]
					pbr_metallic_roughness = material["pbrMetallicRoughness"]
					
					base_color_texture = nil
					base_color_factor = nil
					texture_id = nil
					
					if pbr_metallic_roughness != nil
						base_color_texture = pbr_metallic_roughness["baseColorTexture"]
						base_color_factor = pbr_metallic_roughness["baseColorFactor"]
					else
						# SketchFab extensions
						extensions = material["extensions"]
						if extensions != nil
							pbrSpecularGlossiness = extensions["KHR_materials_pbrSpecularGlossiness"]
							if pbrSpecularGlossiness != nil
								diffuseFactor = pbrSpecularGlossiness["diffuseFactor"]
								if diffuseFactor != nil
									base_color_factor = diffuseFactor
								end
								
								diffuseTexture = pbrSpecularGlossiness["diffuseTexture"]
								if diffuseTexture != nil
									texture_id = diffuseTexture["index"]
								end
							end
						end
					end
					double_sided = material["doubleSided"]
					
					if base_color_texture != nil
						texture_id = base_color_texture["index"]
					end
					if texture_id == nil
						# if the emissive texture exists instead, use it for diffuse
						et = material["emissiveTexture"]
						if et != nil
							texture_id = et["index"]
						end
					end					
					m = GltfMaterial.new(name, texture_id, base_color_factor, double_sided)
					materials.push(m)
				}
			end
		end
	end
end
