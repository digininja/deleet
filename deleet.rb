#!/usr/bin/env ruby

#
# == deleet: Take a wordlist and remove 1337 spellings from it
#
# Original Author:: Robin Wood (robin@digi.ninja)
# Version:: 0.1 alpha
# Copyright:: Copyright(c) 2017 Robin Wood - https://digi.ninja
#

require 'getoptlong'

#
# Display the usage
def usage
	puts "deleet version #{VERSION} Robin Wood (robin@digi.ninja) <https://digi.ninja>

Basic usage:

./deleet.rb --file wordlist.txt

Usage: deleet.rb [OPTION]
	--file, -f: The file to parse
	--output, -o: The file to write to
	--verbose, -v: more output (currently nothing extra to show)
	--debug, -d: debug information

"
	exit
end

leet_swap = {
	'1' => ['i', 'l'],
	'3' => ['e'],
	'4' => ['a'],
	'5' => ['s'],
	'6' => ['b'],
	'7' => ['t'],
	'8' => ['b'],
	'0' => ['o'],
}

VERSION="0.1 alpha"

opts = GetoptLong.new(
	['--help', '-h', "-?", GetoptLong::NO_ARGUMENT],
	['--file', '-f', GetoptLong::REQUIRED_ARGUMENT],
	['--output', '-o', GetoptLong::REQUIRED_ARGUMENT],
	['--debug', '-d', GetoptLong::NO_ARGUMENT],
	['--verbose', '-v', GetoptLong::NO_ARGUMENT]
)

@input_file_handle = STDIN
@output_handle = STDOUT
@debug = false
@verbose = false

begin
	opts.each do |opt, arg|
		case opt
		when '--file'
			if arg == '-'
				@input_file_handle = STDIN
			else
				if File.exist? arg
					@input_file_handle = File.new(arg, 'r')
				else
					puts 'The specified file does not exist'
					exit
				end
			end
		when '--output'
			if arg == '-'
				@output_handle = STDOUT
			else
				begin
					@output_handle = File.new(arg, 'w')
				rescue Errno::EACCES
					puts "Could not create the output file"
					exit
				end
			end
		when '--help'
			usage
		when '--debug'
			@debug = true
		when '--verbose'
			@verbose = true
		end
	end
rescue => e
	puts e
	usage
	exit
end

if @input_file_handle.nil?
	puts 'No input file specified'
	puts
	usage
	exit
end

def leet_variations (str, swap)
  swap_all = Hash.new { |_,k| [k] }.merge(swap) 
  arr = swap_all.values_at(*str.chars)
  arr.shift.product(*arr).map(&:join)
end

@input_file_handle.each do |word|
	word.chomp!
	hits = /^[^a-z]*([a-z0-9]*[a-z])[^a-z]*$/i.match(word)

	if not hits.nil? and hits.length > 0 and hits[1].length > 0 then
		trimmed = hits[1]
		puts word + " = " + trimmed if @debug
		leetarr = leet_variations(trimmed, leet_swap)
		leetarr.each do |leetvar|
			@output_handle.puts leetvar
		end
	end
end
