#!/bin/env ruby
require 'webrick'

s = WEBrick::GenericServer.new( :Port => 2000 )
trap("INT"){ s.shutdown }
s.start do |sock|
  sock.print(Time.now.to_s + "\r\n")
end
