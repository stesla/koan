#!/usr/bin/env ruby
require 'webrick'

s = WEBrick::GenericServer.new( :Port => 2000 )
trap("INT"){ s.shutdown }
s.start do |sock|
  $stderr.print("Connection from " + sock.peeraddr[3].to_s + ':' +
                sock.peeraddr[1].to_s + "\n")

  while true do
    request = ""
    begin
      request += sock.recv(255)
    end until request.match(%r{\n}m)
    break if request.match(%r{quit}i)
    $stderr.print("Recieved: " + request.chomp + "\n")
    sock.print("You said: " + request.chomp + "\n")
  end
end
