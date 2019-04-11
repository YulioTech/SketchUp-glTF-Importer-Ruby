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
Sketchup.require 'yulio_gltf_import/gltf_file'
Sketchup.require 'yulio_gltf_import/gltf_buffer'
Sketchup.require 'yulio_gltf_import/gltf_buffer_view'
Sketchup.require 'yulio_gltf_import/gltf_image'
Sketchup.require 'yulio_gltf_import/gltf_accessor'
Sketchup.require 'yulio_gltf_import/gltf_texture'
Sketchup.require 'yulio_gltf_import/gltf_material'
Sketchup.require 'yulio_gltf_import/gltf_mesh'
Sketchup.require 'yulio_gltf_import/gltf_node'
Sketchup.require 'yulio_gltf_import/gltf_scene'
Sketchup.require 'yulio_gltf_import/gltf_import_component'

# version 1.0.0

# Limitations:
#   Only supports polygon meshes (triangle strips), does support support line imports.
#   Cannot deal with Vertex Coloured meshes (as Sketchup can't deal with them)
#   Does not support Normal maps, PBR material roughness, etc. Only diffuse maps and basic colours.

module Yulio
	module GltfImporter
		class GltfImporter
		
			def initialize()
				@buffers = []
				@buffer_views = []
				@accessors = []
				@images = []
				@textures = []
				@materials = []
				@meshes = []
				@nodes = []
				@scenes = []
				@temporary_files = []
				@material_cache = {}
			end
			
			def import(filename)
				#SKETCHUP_CONSOLE.show
				
				# internal scaling factor for tiny surface import (e.g. Avocado), convert from metres to inches
				#
				
				begin	
					@cpointpos = 0.0
					@internal_scale = 32768.0 #39.37008 * 1000.0
					file_path = File.dirname(filename)
					
					json = GltfFile.read(filename, @buffers)
					
					GltfBuffer::read_buffers(json,@buffers,file_path)
					GltfBufferView::read_buffer_views(json, @buffers, @buffer_views)
					GltfImage::get_images(json,@buffer_views,@images, file_path)
					#i = 0
					#@images.each { |image|
					#	image.save_image("c:/temp/image" + i.to_s)
					#	i = i + 1
					#}
					GltfAccessor::get_accessors(json, @buffer_views, @accessors)
					#puts "accessor count: " + @accessors.length.to_s
							
					GltfTexture::get_textures(json, @textures)
					GltfMaterial::get_materials(json, @materials)
					GltfMesh::get_meshes(json, @meshes)
					GltfNode::get_nodes(json, @nodes)
					GltfScene::get_scenes(json, @scenes)
					
					#puts json
					version = json["asset"]["version"]
					
					puts TRANSLATE["version"] + version
					if version.to_f < 2.0
						UI.messagebox(TRANSLATE["invalidFormat"],  MB_MULTILINE, TRANSLATE["title"])
						return 1
					end
					
					scene_id = json["scene"]
					if scene_id == nil
						scene_id = 0
					end
					scene = @scenes[scene_id]
					
					matrix = get_default_matrix()
					nodes = scene.get_nodes()
					@components = GltfImportComponent.new(@nodes, nodes)
					
					Sketchup.active_model.start_operation TRANSLATE["title"],true,false,false
					group = Sketchup.active_model.entities.add_group
					
					#point1 = Geom::Point3d.new(-1.0,-1.0,-1.0)
					#constpoint = group.entities.add_cpoint point1
				
					group.transformation = matrix
					
					nodes.each { |node_id|
						node = @nodes[node_id]
						import_node(group.entities, node, matrix)
					}
					
				rescue => e
					Sketchup.active_model.abort_operation
					
					# something went wrong, log the error so the user can give feedback to me
					msg = TRANSLATE["error"]
					msg = msg << "\n"
					msg = msg << e.inspect 
					msg = msg << "\n"
					msg = msg << "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
					
					UI.messagebox(msg, MB_MULTILINE, TRANSLATE['title'])
					return 1
				end
				
				
				Sketchup.active_model.commit_operation
					
				puts "glTF import complete"
				
				# zoom to extents
				Sketchup.active_model.active_view.zoom_extents
				
				# refresh the screen
				Sketchup.active_model.active_view.invalidate
				
				# cleanup temporary files
				@temporary_files.each { |file|
					File.delete(file)
				}
				# return 0 for successful import
				return 0
			end

			
			
			def import_node(entities, node, matrix)
				#puts "import"
				
				mesh_id = node.get_mesh()
				mtx = node.get_matrix()
				
				group = entities.add_group
				#point1 = Geom::Point3d.new(0,0,0)
				#constpoint = group.entities.add_cpoint point1
				
				group.transformation = mtx
				#matrix = mtx * matrix
				#point1 = Geom::Point3d.new(@cpointpos,@cpointpos,@cpointpos)
				#@cpointpos = @cpointpos + 1.0
				#constpoint = group.entities.add_cpoint point1
				
				
				if mesh_id != nil
					
					scale_up = IDENTITY
					scale_down = IDENTITY
					if(@internal_scale != 1.0)
						scale_down = Geom::Transformation.scaling(1.0/@internal_scale,1.0/@internal_scale,1.0/@internal_scale)
						scale_up = Geom::Transformation.scaling(@internal_scale,@internal_scale,@internal_scale)
					end
					#group = group.entities.add_group
					
					# add another group for the scale-down
					
					
					
					# create a construction point to prevent the garbage collector destroying our as-yet-unused group
					
					
					# make a component if the mesh is referenced multiple times
					if @components.is_mesh_component(mesh_id)
						#puts 'Found component'
						component = @components.get_component_definition(mesh_id)
						if component == nil
							# The component does not exist, create it
							meshName = @meshes[mesh_id].get_name()
							if meshName == nil
								meshName = "mesh_id_" + mesh_id.to_s
							end
							component = Sketchup.active_model.definitions.add meshName
							
							#point1 = Geom::Point3d.new(0,0,0)
							#constpoint = component.entities.add_cpoint point1
							group2 = component.entities.add_group
							group2.transformation = scale_down
							
							#point1 = Geom::Point3d.new(@cpointpos,@cpointpos,@cpointpos)
							#@cpointpos = @cpointpos + 1.0
							#constpoint2 = group2.entities.add_cpoint point1
							
							create_mesh(group2, mesh_id, scale_up)
							
							
							@components.add_component_definition(mesh_id, component)
							#if !constpoint2.deleted?
#								constpoint2.erase!
	#						end
						end
						# add the instance
						
						group.entities.add_instance(component, IDENTITY)
					else
						group2 = group.entities.add_group
						group2.transformation = scale_down
						#point1 = Geom::Point3d.new(@cpointpos,@cpointpos,@cpointpos)
						#@cpointpos = @cpointpos + 1.0
						#constpoint = group2.entities.add_cpoint point1
						create_mesh(group2, mesh_id, scale_up)
					end
					#
					
					#puts "mesh_id:" + mesh_id.to_s
					
					
				end
				if(group.deleted?)
					puts 'Group was deleted! - this is a bug in Sketchup'
					return
				end
				
				children = node.get_children()
				
				if(group.deleted?)
					puts 'Group2 was deleted! - this is a bug in Sketchup'
					return
				end
				
				if children != nil
					children.each { |child_id|
						child = @nodes[child_id]
						import_node(group.entities, child, matrix)
						#import_node(entities, child, matrix)
					}
				end
				
				#if !constpoint.deleted?
				#	constpoint.erase!
				#end
				
			end
			
			
			def get_default_matrix()
				trans = Geom::Transformation.new
				
				# rotate the model from OpenGL to Sketchup axis representations
				trans = trans * Geom::Transformation.rotation([0,0,0], [0,1,0], Math::PI)
				trans = trans * Geom::Transformation.rotation([0,0,0], [1,0,0], -Math::PI/2.0)
				trans = trans * Geom::Transformation.rotation([0,0,0], [0,0,1], Math::PI)
				
				# scale the final model from metres to inches
				n = 39.37008
				trans = trans * Geom::Transformation.scaling(n,n,n)
				return trans
			end
			
			def add_material(name, r,g,b,a, texture)
				nr = (r*255.0).to_i
				ng = (g*255.0).to_i
				nb = (b*255.0).to_i
				na = (a*255.0).to_i
				
				
				if name == nil
					name = 'M' + nr.to_s + '_' + ng.to_s + '_' + nb.to_s + '_' + na.to_s
				end
				
				#puts name
				#puts nr.to_s + ' ' + ng.to_s + ' ' + nb.to_s + ' ' + na.to_s + ' ' 
				material = Sketchup.active_model.materials.add name
				if texture != nil
					material.texture = texture
					#puts materialName + ' ' + materialTexture
				else
					colourNew = Sketchup::Color.new(nr,ng,nb,na)
					material.color = colourNew
					# apply alpha to the material
					if a != 1.0
						material.alpha = a
					end
				end
				return material
			end
			
			
			
			def get_material(material_id)
				if material_id == nil
					# default material
					return nil
				end
				
				material = @material_cache[material_id]
				
				
				if material == nil
					mat = @materials[material_id]
					name = mat.get_name()
					
					#puts 'material name:' + name
					texture_id = mat.get_texture_id()
					if(texture_id != nil)
						source_id = @textures[texture_id].get_source_id()
						image = @images[source_id]
						# write the texture to file...
						filename = image.save_temp_image()
						material = add_material(name, 0,0,0,0, filename)
						# queue the file for deletion.
						@temporary_files.push(filename)
					else
						rgba = mat.get_color()
						
						
						# debug!!!
						#puts rgba[0].to_s + ' ' + rgba[1].to_s + ' ' + rgba[2].to_s + ' ' + rgba[3].to_s + ' ' 
						
						material = add_material(name, rgba[0], rgba[1], rgba[2], rgba[3], nil)
						# todo: Do we need to set material.alpha?
						#material.alpha = rgba[3] / 255.0
					end
					@material_cache[material_id] = material
				end
				return material
			end
			
			
			
			def create_mesh(group, mesh_id, mtinternal_scale)
				mesh = @meshes[mesh_id]
				primitives = mesh.get_primitives()
				
				face_indices = Hash.new
				
				primitives.each { |primitive|
					#puts "primitive"
					
					normal_id = primitive.get_normal()
					position_id = primitive.get_position()
					texcoord_id = primitive.get_texcoord()
					material_id = primitive.get_material()
					color_id = primitive.get_color()
					
					if position_id == nil
						raise TRANSLATE["noPosition"]
					end
					
					position = @accessors[position_id].get_vector3()
					
					indices_id = primitive.get_indices()
					if indices_id == nil
						# create the indices
						indices = []
						i = 0
						while i < position.length
							indices[i] = i
						end
					else
						indices = @accessors[indices_id].get_indices()
					end
					
					if normal_id == nil
						normal = nil
					else
						normal = @accessors[normal_id].get_vector3()
					end
					
					
					texcoord = nil
					if texcoord_id != nil
						texcoord = @accessors[texcoord_id].get_vector2()
					end
					
					colors = nil
					if color_id != nil
						colors = @accessors[color_id].get_colors()
					end
					
					begin
						create_mesh_geometry(face_indices, group.entities, mtinternal_scale, indices, normal, position, texcoord, material_id, colors)
					rescue
						if group.deleted?
							# todo: log a warning
							puts "Group was deleted!"
							return
						end
					end
					
					#if group.deleted?
						#puts 'Group was deleted! - this is a bug in Sketchup'
						#group = entities.add_group
						#return
					#end
				}
				
				# smooth edges based on normals
				# find all shared edges, and smooth them
				group.entities.each { |e|
					if e.class == Sketchup::Edge
						edge = e
						edge.hidden = true
						edge.soft = true
						if edge.faces.length == 2
							face0 = edge.faces[0]
							face1 = edge.faces[1]
							if face_shares_an_edge(face_indices[face0],face_indices[face1])
								edge.smooth = true
							end
						end
					end
				}
			end
			
			
			# determine if a face shares an edge based on the indices, because if so, we can
			# be assured that the face is sharing a normal, and that therefore the edge is smooth.
			def face_shares_an_edge(indices1, indices2)
				
				if indices1 == nil || indices2 == nil
					return false
				end
				c = 0
				indices1.each { |i|
					indices2.each { |j|
						if i == j
							c = c + 1
							break
						end
					}
				}
				if c == 2
					return true
				end
				return false
			end
			
			
			
			

			def create_mesh_geometry_mesh(face_indices, entities, matrix, indices, normal, position, texcoord, material_id)
				# todo: process vertex colours, get average of each colour for the face material
				material= get_material(material_id)
				if material == nil
					is_double_sided = false
				else
					is_double_sided = @materials[material_id].is_double_sided()
				end
				
				
				# transform all points in position by matrix first
				t_positions = []
				position.each { |p|
					pt = Geom::Point3d.new(p[0], p[1], p[2])
					if matrix.identity? == false
						pt.transform! matrix
					end
					t_positions.push(pt)
				}
				
				#puts 'Indices:' + indices.length.to_s
				
				#uv_array = []
				#normal_array = []
				#indice_array = []
				face_count = 0
				
				#hash = Hash.new
				mesh = Geom::PolygonMesh.new
				i = 0
				while i < indices.length
					j = 0
					#meshIndices = []
					#pt_array = []
					#pt_normals = []
					#pt_indices = []
					while j < 3
						index = indices[i+j]
						point = t_positions[index]
						#pt_indices.push(index)
						#if normal != nil
						#	n = normal[index]
						#	pt_normals.push(n)
						#end
						#if(texcoord != nil)
						#	t = texcoord[index]
						#	pt_array.push(point)
						#	pt_array.push(Geom::Point3d.new(t[0],1.0-t[1],0.0))
						#end
						
						meshIndex = mesh.add_point point
						meshIndices.push(meshIndex)
						j = j + 1
					end
					mesh.add_polygon(meshIndices[0], meshIndices[1], meshIndices[2])
					face_count = face_count + 1
					i = i + 3
					
					# for the face just added, store the normals and the pt_array for texture positioning
					#normal_array.push(pt_normals)
					#uv_array.push(pt_array)
					#indice_array.push(pt_indices)
				end
				
				#mesh.add_polygon 1,2,3
				
				# map the existing faces
				#existing = Hash.new
				#entities.each { |e|
				#	if(e.class == Sketchup::Face)
				#		face = e
				#		existing[face.entityID] = 1
				#	end
				#}
				
				puts 'Adding faces from mesh'
				entities.add_faces_from_mesh(mesh,  Geom::PolygonMesh::NO_SMOOTH_OR_HIDE, material)
				
				# The following code relies on an undocumented feature, that the faces are in the same order as added to in the mesh
				#i = 0
				#entities.each { |e|
					#if(e.class == Sketchup::Face)
						
						#puts 'face' + i.to_s + '/' + face_count.to_s
						#face = e
						#if existing[face.entityID] == nil
						
							#puts 'Found face ' + i.to_s
							# correct orientation
							#n = nil
							#if normal_array[i].length > 0
							#	n = normal_array[i][0]
							#	dot = face.normal.dot n
							#	if dot < 0.0
							#		#puts 'Reversing face'
							#		face.reverse!
							#	end
							#end
							
							# set face indices
							#face_indices[face] = indice_array[i]
							
							# apply texture position
							#if uv_array[i].length > 0
								#puts 'Applying UV'
							#	if(texcoord != nil)
							#			begin
							#				face.position_material face.material, uv_array[i], true
							#				#puts 'Applying UV2'
							#				if is_double_sided
							#					face.position_material face.back_material, uv_array[i], false
							#				end
							#			rescue
							#			end
							#		end
							#end
							
							#i = i + 1
						#end
					#end
				#}
				
				#puts 'face count:' + face_count.to_s
				#puts 'face count:' + i.to_s
			end

			
			def create_mesh_geometry(face_indices, entities, matrix, indices, normal, position, texcoord, material_id, colors)

				#if texcoord == nil
				#	create_mesh_geometry_mesh(face_indices, entities, matrix, indices, normal, position, texcoord, material_id)
				#	return
				#end
				
				# todo: process vertex colours, get average of each colour for the face material
				material= get_material(material_id)
				if material == nil
					is_double_sided = false
				else
					is_double_sided = @materials[material_id].is_double_sided()
				end
				# debug!!!
				#return
				
				
				# transform all points in position by matrix first
				t_positions = []
				position.each { |p|
					pt = Geom::Point3d.new(p[0], p[1], p[2])
					if matrix.identity? == false
						pt.transform! matrix
					end
					t_positions.push(pt)
				}
				
				
				i = 0
				while i < indices.length
					
					points = []
					normals = []
					pt_array = []
					indice_array = []
					
					n = nil
					j = 0
					
					i0 = indices[i]
					i1 = indices[i+1]
					i2 = indices[i+2]
					if((i0 == i1) || (i1 == i2) || (i0 == i2))
						puts 'Duplicate index ' + i.to_s + ':' + i0.to_s + ' ' + i1.to_s + ' ' + i2.to_s
					end
					
					while j < 3
						index = indices[i+j]
						indice_array.push(index)
						pt = t_positions[index]
						if normal != nil
							n = normal[index]
							normals.push(n)
						end
						
						points.push(pt)
						
						if(texcoord != nil)
							t = texcoord[index]
							pt_array.push(pt)
							pt_array.push(Geom::Point3d.new(t[0],1.0-t[1],0.0))
						end
						j = j + 1
					end
					
					if colors != nil
						material = add_material(nil, colors[i][0], colors[i][1], colors[i][2], colors[i][3], nil)
					end
					
					begin
						#dist0 = points[0].distance points[1]
						#dist1 = points[1].distance points[2]
						#dist2 = points[0].distance points[2]
						
						#if dist0 > 0.005 && dist1 > 0.005 && dist2 > 0.005
						
							face = entities.add_face points
							
							# store the indice array for this face
							face_indices[face] = indice_array
							
							if n != nil
								# flip the new face is it is not facing the correct direction according to the provided normals
								dot = face.normal.dot n
								if dot < 0.0
									face.reverse!
								end
							end
							
							if material != nil
								face.material = material
								if is_double_sided
									face.back_material = material
								end
								
								if(texcoord != nil)
									begin
										face.position_material face.material, pt_array, true
										if is_double_sided
											face.position_material face.back_material, pt_array, false
										end
									rescue
									end
								end
							end
						#end
						
					rescue #=> e
						#puts 'Error - face could not be created'
						#puts e.inspect
						#puts points[0]
						#puts points[1]
						#puts points[2]
						#return
						# todo: count the number of faces that could not be created
					end
				
					i = i + 3
				end
			end
		end
	end
end
