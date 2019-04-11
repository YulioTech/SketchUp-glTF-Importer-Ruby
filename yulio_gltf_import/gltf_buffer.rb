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

require 'base64'

module Yulio
	module GltfImporter

		class GltfBuffer
			def initialize()
				@buffer = ''
				@byte_length = 0
				@buffer_num = 0
			end
			
			def add_bytes(bytes)
				@buffer = bytes
				@byte_length = bytes.length
			end
			
			def read_buffer(uri, byte_length, file_path, buffer_num)
				@buffer_num = buffer_num
				#                   0123456789012345678901234567890123456789
				if(uri.start_with?("data:application/octet-stream;base64,"))
					#puts 'base64:' + uri[37..55]	#
					@buffer = Base64.decode64(uri[37..-1])
					@byte_length = byte_length
					#puts 'Added base-64 encoded data ' + @byte_length.to_s + ' bytes'
					return
				end
				
				# duck.bin  (filename)
				filename = File.join(file_path, uri)
				file = File.open(filename)
				@buffer = file.read(byte_length)
				@byte_length = byte_length
				file.close()
			end
			
			def get_bytes(i,cb)
				#puts 'accessing buffer ' + @buffer_num.to_s + ' @ ' + i.to_s + ' length(' + cb.to_s + ')'
				#tmp = @buffer[i,10]
				#puts tmp.unpack('H*')
				
				#(0..10).each { |j|
				#		puts j.to_s + ' ' + @buffer[i+j].to_s(16)
				#}
				return @buffer[i,cb]
			end
			
			# static method (GltfBuffer::read_buffers(json,buffers))
			def self.read_buffers(json, buffers, file_path)
				bufs = json["buffers"]
				bufs.each { |buffer|
					if(buffer["uri"] == nil)
						next
					end
					buf = GltfBuffer.new()
					buf.read_buffer(buffer["uri"], buffer["byteLength"], file_path, buffers.length)
					buffers.push(buf)
				}
			end
		end

	end
end
