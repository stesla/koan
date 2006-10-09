#!/usr/bin/env ruby

require "date"

def usage
  $stderr.puts "USAGE: #{File.basename(__FILE__)} source-dir dest-dir"
  exit 1
end

class LogFile
  def initialize(path)
    @path = path
    parse_path
    load_file
  end

  def load_file
    @log_text = File.open(@path){|io| io.read}
  end

  def write_to_directory(directory)
    File.open("#{directory}/#{new_file_name}","w") do
      |io|
      io.puts "World: #{@world}"
      io.puts "Player: #{@player}"
      io.puts "Date: #{@date.to_s}"
      io.puts
      io.puts @log_text
    end
  end

  def parse_path
    @name = @path.gsub(/\.[^.]*$/,'')
    regex = Regexp.new('([^/]+)/([^/]+)/(\d+)/(\d+)/(\d+)$')
    match_data = regex.match(@name)
    return if match_data.nil?
    @world = match_data[1]
    @player = match_data[2]
    year = match_data[3].to_i
    month = match_data[4].to_i
    day = match_data[5].to_i
    @date = Date.new(year, month, day)
  end

  def new_file_name
    "#{@world}-#{@player}-#{@date.to_s}.koanlog"
  end
end

class LogEnumerator
  def initialize(directory)
    @directory = directory
  end

  def each(&block)
    Dir["#{@directory}/**/*.txt"].each {|each| block.call(LogFile.new(each))}
  end
end

usage unless ARGV.size == 2
source = ARGV[0].gsub(/\/$/,'')
destination = ARGV[1].gsub(/\/$/,'')
Dir.mkdir destination unless File.exists? destination

LogEnumerator.new(source).each do
  |each|
  puts "Writing #{each.new_file_name}"
  each.write_to_directory(destination)
end
