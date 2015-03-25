require 'socket'
require 'json'

server = TCPServer.open(2000)

def send_results(client, target)
    content = File.open(target.to_s[1..-1]).read
    client.puts "#{Time.now}"
    client.puts "Content-Length: #{content.length}\r\n\r\n"
    client.puts content
end

loop {
  Thread.start(server.accept) do |client|

    request = client.read_nonblock(256)
    headers, body = request.split("\r\n\r\n", 2)
    http_method = headers.match(/\w+/)                  # I use regex for training purposes
    http_request = headers.match(/\/(?:[\w-]+\/?\.?)+/) 
    http_version = headers.match(/HTTP.*[0-9]/)         
    status_messages = {200 => "OK", 404 => "Not found", 400 => "Bad request"}

    if File.exists? http_request.to_s[1..-1]
      status_code = 200
      if http_method.to_s == "GET"
        client.puts "#{http_version} #{status_code} #{status_messages[status_code]}"
        send_results(client, http_request)
      elsif http_method.to_s == "POST"
        f = File.read(http_request.to_s[1..-1])
        params = JSON.parse(body)
        form_content = "<li>Name: #{params['viking']['name']}</li><li>Email: #{params['viking']['email']}</li>"
        client.puts "#{http_version} #{status_code} #{status_messages[status_code]}\r\n\r\n"
        client.puts f.gsub('<%= yield %>', form_content)
      end
    else
      status_code = 404
      client.puts "#{http_version} #{status_code} #{status_messages[status_code]}\n"
    end

    client.puts "\nClosing connection."
    client.close
  end
}