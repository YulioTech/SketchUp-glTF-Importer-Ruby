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
require 'tmpdir'
require 'base64'

module Yulio
	module GltfImporter
		
		class GltfImage
			def initialize(image_bytes, mime_type)
				@image_bytes = image_bytes
				@mime_type = mime_type	# e.g. 'image/jpeg'
			end
			
			def get_mime_type()
				return @type
			end
			
			def get_image_bytes()
				return @image_bytes
			end
			
			def save_temp_image()
				# create a random file in the tmp directory
				ext = '.png'
				if @mime_type == 'image/jpeg'
					ext = '.jpg'
				end
				n = Random.rand(100000) + 100000
				filename = File.join(Dir.tmpdir() , n.to_s + ext)
				#filename.gsub!(':','_')
				
				file =  File.open(filename,"wb")
				file.write(@image_bytes)
				file.close()
				return filename
			end
			
			def save_image(filename)
				ext = '.png'
				if @mime_type == 'image/jpeg'
					ext = '.jpg'
				end
				file = File.open(filename+ext,"wb")
				file.write(@image_bytes)
				file.close()
			end
			
			# "images": [
      #  {
      #      "uri": "data:image/png;base64,iVBORw0..."
      #  }
			#],
			def self.get_images(json, buffer_views, images, file_path)
				ims = json["images"]
				if ims == nil
					return
				end
				ims.each { |image|
					
					mime_type = image["mimeType"]
					
					buffer_view = image["bufferView"]
					if buffer_view != nil
						bv = buffer_views[buffer_view]
						image_bytes = bv.get_bytes(0, -1)
						a = GltfImage.new(image_bytes, mime_type)
						images.push(a)
					end
					
					uri = image["uri"]
					if uri != nil
					
						#                   0123456789012345678901
						if(uri.start_with?("data:image/png;base64,"))
							image_bytes = Base64.decode64(uri[22..-1])
							mime_type = 'image/png'
							a = GltfImage.new(image_bytes, mime_type)
							images.push(a)
							return
						end
						
						#                   01234567890123456789012
						if(uri.start_with?("data:image/jpeg;base64,"))
							image_bytes = Base64.decode64(uri[23..-1])
							mime_type = 'image/jpeg'
							a = GltfImage.new(image_bytes, mime_type)
							images.push(a)
							return
						end
						
						file = uri.gsub(':','_')
						filepath = File.join(file_path, file)
						image_bytes = IO.binread(filepath)
						if mime_type == nil
							ext = uri.split('.').last
							ext.downcase!
							if ext == 'png'
								mime_type = 'image/png'
							end
							if ext == 'jpg' || ext == 'jpeg'
								mime_type = 'image/jpeg'
							end
						end
						a = GltfImage.new(image_bytes, mime_type)
						images.push(a)
					end
				}
			end
		end
	end
end
