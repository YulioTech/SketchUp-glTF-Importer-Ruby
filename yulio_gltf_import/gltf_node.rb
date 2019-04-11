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
		class GltfNode
			
			def initialize(nodeId,mesh_id,children,matrix, translation, rotation, scale)
				@mesh_id = mesh_id
				@children = children
				
				#puts 'NodeId:' + nodeId.to_s
				
				
				if matrix != nil
					#puts 'Matrix'
					#matrix = get_identity()
					#display_matrix(matrix)
					@matrix = get_transformation(matrix)
				else
					if translation == nil
						translateTransform = get_transformation(get_identity())
					else
						#puts 'Translation'
						translate = Geom::Point3d.new(translation[0].to_f,translation[1].to_f,translation[2].to_f)
						translateTransform = Geom::Transformation.translation(translate)
					end
					if rotation == nil
						rotationTransform = get_transformation(get_identity())
					else
						#2017-08-11 Negative rotation axis seems to work, check on more model samples which use quaternion rotations.
						# or pass just the negative w?
						rm = get_rotation_matrix(-rotation[0].to_f,-rotation[1].to_f,-rotation[2].to_f,rotation[3].to_f)
						#rm = get_identity()
						#display_matrix(rm)
						rotationTransform = get_transformation(rm)
					end
					if scale == nil
						scaleTransform = get_transformation(get_identity())
					else
						#puts 'Scale'
						scaleTransform = Geom::Transformation.scaling(scale[0],scale[1],scale[2])
					end
					# create new matrix here from TRS
					@matrix = scaleTransform * rotationTransform * translateTransform
				end
				#puts 'Sketchup'
				#display_matrix(@matrix.to_a)
			end

			def display_matrix(mtx)
				puts '-------------------------------------'
				puts mtx[0].to_s + ' ' + mtx[1].to_s + ' ' + mtx[2].to_s + ' ' + mtx[3].to_s
				puts mtx[4].to_s + ' ' + mtx[5].to_s + ' ' + mtx[6].to_s + ' ' + mtx[7].to_s
				puts mtx[8].to_s + ' ' + mtx[9].to_s + ' ' + mtx[10].to_s + ' ' + mtx[11].to_s
				puts mtx[12].to_s + ' ' + mtx[13].to_s + ' ' + mtx[14].to_s + ' ' + mtx[15].to_s
				puts '-------------------------------------'
			end

			
			def get_rotation_matrix(qx,qy,qz,qw)
				# convert a quaternion to a rotation matrix
				m = get_identity()
				
				#qnorm = 1.0 / Math::sqrt(qx*qx + qy * qy + qz*qz + qw*qw)
				#qx = qx * qnorm
				#qy = qy * qnorm
				#qz = qz * qnorm
				#qw = qw * qnorm
				
				m[0] = 1.0 - 2.0*qy*qy - 2.0*qz*qz
				m[1] = 2.0*qx*qy - 2.0*qz*qw
				m[2] = 2.0*qx*qz + 2.0*qy*qw
				
				m[4] = 2.0*qx*qy + 2.0*qz*qw
				m[5] = 1.0 - 2.0*qx*qx - 2.0*qz*qz
				m[6] = 2.0*qy*qz - 2.0*qx*qw
				
				m[8] = 2.0*qx*qz - 2.0*qy*qw
				m[9] = 2.0*qy*qz + 2.0*qx*qw
				m[10] = 1.0 - 2.0*qx*qx - 2.0*qy*qy
				return m
			end
			
			def transpose(mtx)
				(0..3).each { |i|
					(0..3).each { |j|
						if(i>j)
							tmp = mtx[i*4+j]
							mtx[i*4+j] = mtx[j*4+i]
							mtx[j*4+i] = tmp
						end
					}
				}
				return mtx
			end
			
			def get_mesh()
				return @mesh_id
			end
			def get_children()
				return @children
			end
			
			def get_transformation(matrix)
				mtx = Geom::Transformation.new(matrix)
				#mtx = Geom::Transformation.new([
				#	matrix[0],matrix[4],matrix[ 8],matrix[12],
				#	matrix[1],matrix[5],matrix[ 9],matrix[13],
				#	matrix[2],matrix[6],matrix[10],matrix[14],
				#	matrix[3],matrix[7],matrix[11],matrix[15]])
				return mtx
			end
			
			def get_identity()
				return [1.0,0.0,0.0,0.0,
								0.0,1.0,0.0,0.0,
								0.0,0.0,1.0,0.0,
								0.0,0.0,0.0,1.0]
			end
			
			def get_matrix()
				# default [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]
				return @matrix
			end
			
			def self.get_nodes(json, nodes)
				json["nodes"].each { |node|
					children = node["children"]
					mesh = node["mesh"]
					matrix = node["matrix"]
					rotation = node["rotation"]
					scale = node["scale"]
					translation = node["translation"]
					nodeId = nodes.length
					n = GltfNode.new(nodeId,mesh, children, matrix, translation, rotation, scale)
					nodes.push(n)
				}
			end
		end
	end
end
