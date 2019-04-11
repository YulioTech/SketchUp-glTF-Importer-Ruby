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
		class GltfImportComponent

			# this class determines if the mesh being imported can be a component definition
			# by counting the occurences of the mesh within the model.
			def initialize(nodes, scene_nodes)
				@mesh_references = {}
				@component_definitions = {}
				@nodes = nodes
				
				# json["nodes"]
				scene_nodes.each { |node_id|
					get_mesh_counts(node_id)
				}
			end
			
			def get_mesh_counts(node_id)
				node = @nodes[node_id]
				children = node.get_children()
				mesh_id = node.get_mesh()
				
				if mesh_id != nil
					c = @mesh_references[mesh_id]
					if c == nil
						@mesh_references[mesh_id] = 1
					else
						c = c + 1
						@mesh_references[mesh_id] = c
					end
				end
				
				if children != nil
					children.each { |child_id|
						get_mesh_counts(child_id)
					}
				end
			end
			
			def is_mesh_component(mesh_id)
				if @mesh_references[mesh_id] > 1
					return true
				end
				return false
			end
			
			def get_component_definition(mesh_id)
				return @component_definitions[mesh_id]
			end
			
			def add_component_definition(mesh_id, component_definition)
				@component_definitions[mesh_id] = component_definition
			end
			
		end
	end
end
