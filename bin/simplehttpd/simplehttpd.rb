require "socket"

def elapse(t0, t1)
	dt = t1 - t0
	"Elapse : #{t0} -> #{t1}: #{sprintf("%10.5e", dt)}\n"
end

def get_instance_id
	instance_id = `curl http://169.254.169.254/latest/meta-data/instance-id`

	"instance-id: #{instance_id}\n"
end

port = 80
server = TCPServer.open(port)

while true
	Thread.start(server.accept) do |socket|
		p socket.peeraddr

		is_get        = false
		end_of_header = false
		req_time      = 0
    puts Time.now
		while request = socket.gets
			t0 = Time.now
			puts "> #{request}"

			if request.include? "GET"
				is_get = true
				if request =~ /GET \/([^ ]*)/
					req_time = $~[1].to_i
				end

				puts "REQUIRED TIME: #{req_time}"
			end
			end_of_header = true if request == "\r\n"

			if is_get && end_of_header 

				msg = '0' * req_time

				body_size = (get_instance_id + msg + "\n" + elapse(Time.now, Time.now)).bytesize
				#header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Length: #{body_size}\r\nSet-Cookie: TEST=abc\r\n\r\n"
				header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Length: #{body_size}\r\n\r\n"
				socket.write header

				#socket.write '<link rel="shortcut icon" href="about:blank">'

				socket.write get_instance_id

				msg.each_char do |c|
					socket.write c
					sleep 1
				end

				socket.write "\n"

				t1 = Time.now
				socket.write elapse(t0, t1)

				is_get        = false
				end_of_header = false
			end
		end

		puts Time.now
		puts "Closing"

		socket.close
	end

end

server.close
