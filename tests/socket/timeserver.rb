#!/usr/bin/env ruby
require 'webrick'

s = WEBrick::GenericServer.new( :Port => 2000 )
trap("INT"){ s.shutdown }
s.start do |sock|
  $stderr.print("Connection from " + sock.peeraddr[3].to_s + ':' +
                sock.peeraddr[1].to_s + "\n");
  sock.print(Time.now.to_s + "\r\n")
end
