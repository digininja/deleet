#!/usr/bin/env ruby
#encoding: UTF-8

#
# == deleet: Take a wordlist and remove 1337 spellings from it
#
# Original Author:: Robin Wood (robin@digi.ninja)
# Version:: 0.1 alpha
# Copyright:: Copyright(c) 2017 Robin Wood - https://digi.ninja
#

require 'getoptlong'
require 'zlib'

#
# Display the usage
def usage
	puts "deleet version #{VERSION} Robin Wood (robin@digi.ninja) <https://digi.ninja>

Basic usage:

./deleet.rb --file wordlist.txt

Usage: deleet.rb [OPTION]
	--file, -f: The file to parse
	--output, -o: The file to write to
	--ltrim: Strip all non-alpha from the left
	--rtrim: Strip all non-alpha from the right
	--lower, -l: Convert all results to lower case
	--uniq, -u: Strip out duplicates
	--counts, -c: Work out the counts for each word
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
	'@' => ['a'],
	'$' => ['s'],
}

VERSION="0.1 alpha"

opts = GetoptLong.new(
	['--help', '-h', "-?", GetoptLong::NO_ARGUMENT],
	['--ltrim', GetoptLong::NO_ARGUMENT],
	['--rtrim', GetoptLong::NO_ARGUMENT],
	['--lower', '-l', GetoptLong::NO_ARGUMENT],
	['--uniq', '-u', GetoptLong::NO_ARGUMENT],
	['--counts', '-c', GetoptLong::NO_ARGUMENT],
	['--file', '-f', GetoptLong::REQUIRED_ARGUMENT],
	['--output', '-o', GetoptLong::REQUIRED_ARGUMENT],
	['--debug', '-d', GetoptLong::NO_ARGUMENT],
	['--verbose', '-v', GetoptLong::NO_ARGUMENT]
)

@input_file_handle = nil
@output_handle = STDOUT
@debug = false
@verbose = false
@ltrim = false
@rtrim = false
@uniq = false
@lower = false
@counts = false

begin
	opts.each do |opt, arg|
		case opt
		when '--counts'
			@counts = true
		when '--lower'
			@lower = true
		when '--uniq'
			@uniq = true
		when '--rtrim'
			@rtrim = true
		when '--ltrim'
			@ltrim = true
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
	exit
end

if @counts and @uniq
	puts "Setting counts and uniq does not make sense, please choose one or the other"
	puts
	exit
end

def leet_variations (str, swap)
  swap_all = Hash.new { |_,k| [k] }.merge(swap) 
  arr = swap_all.values_at(*str.chars)
  arr.shift.product(*arr).map(&:join)
end

@uniq_crcs = []
@word_cache = {}

@input_file_handle.each do |word|
	word.chomp!
	if @lower
		word.downcase!
	end
	if @ltrim
		word.gsub!(/^[^a-z]*/i, "")
	end
	if @rtrim
		word.gsub!(/[^a-z]*$/i, "")
	end

	if word != "" then
		puts word + " = " + word if @debug
		leetarr = leet_variations(word, leet_swap)
		leetarr.each do |leetvar|
			if @uniq
				crc = Zlib::crc32(leetvar)
				if not @uniq_crcs.include?(crc)
					@output_handle.puts leetvar
					@uniq_crcs << crc
				end
			elsif @counts
				if not @word_cache.has_key?(leetvar)
					@word_cache[leetvar] = 0
				end
				@word_cache[leetvar] += 1
			else
				@output_handle.puts leetvar
			end
		end
	end
end

if @counts then
	@word_cache.each_pair do |word, count|
		@output_handle.puts "#{word} : #{count}"
	end
end

