require 'socket'
require 'json'

host = 'localhost'
port = 2000
valid_methods = ["GET", "POST"]

begin
  puts "Please type HTTP request: "
  method = gets.chomp.upcase 
end until valid_methods.include? method

if method == "POST"
  params = Hash.new { |hash, key| hash[key] = Hash.new }         
  puts "Your viking name?"
  params[:viking][:name] = gets.chomp
  puts "His email?"
  params[:viking][:email] = gets.chomp
  body = params.to_json
  request = "#{method} /thanks.html HTTP/1.0\nContent-Length: #{body.to_s.length}\r\n\r\n#{body}"
else
  puts "Which file do you want to get?"
  path = gets.chomp
  request = "#{method} /#{path} HTTP/1.0\r\n\r\n"
end

socket = TCPSocket.open(host, port)
socket.print(request)
response = socket.read

headers, body = response.split("\r\n\r\n", 2)
if !headers.include? '404'
  puts "#{headers}\r\n\r\n#{body}"
else
  puts "#{headers}\r\n\r\nThe file you requested was not found."
end
