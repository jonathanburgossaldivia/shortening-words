# frozen_string_literal: true

require 'optparse'
require 'yaml'

@config_file = Dir.home.to_s + '/config.yml'
@first_initial = ''
CLEAR = "\e[H\e[2J"

# Add colors to output text
class String
  def red
    colorize(self, "\e[1m\e[31m")
  end

  def green
    colorize(self, "\e[1m\e[32m")
  end

  def dark_green
    colorize(self, "\e[32m")
  end

  def yellow
    colorize(self, "\e[1m\e[33m")
  end

  def blue
    colorize(self, "\e[1m\e[34m")
  end

  def dark_blue
    colorize(self, "\e[34m")
  end

  def pur
    colorize(self, "\e[1m\e[35m")
  end

  def colorize(text, color_code)
    color_code.to_s + text.to_s + "\e[0m"
  end
end

def load_configuration
  config = YAML.load_file(@config_file)
  @lists_path = config[:lists_path]
  @lists_name = config[:lists_name]
  @exceptions_list = config[:exceptions_list]
end

if File.file?(@config_file)
  load_configuration
else
  recipe = { lists_path: Dir.home.to_s + '/lists/', lists_name: '_list.txt', exceptions_list: 'exceptions.txt' }
  File.open('config.yml', 'w') { |file| file.write(recipe.to_yaml) }
  load_configuration
end

puts ::CLEAR
puts ' ' + ' SHORTENING V0.1 '.center(54, '=')
puts ' (for now it works only with plain text files)'.yellow
puts ' Configuration file: '.ljust(22).green + "\"#{@config_file}\"".to_s
puts ' Lists directory: '.ljust(22).green + "\"#{@lists_path}\"".to_s
puts ' ' + ' By Jonathan Burgos '.center(54, '=')

def list_maker(filename)
  print "\n Processing file: \n\n".yellow
  system('rm -rf ' + @lists_path + '*')
  system('mkdir -p ' + @lists_path)
  File.new(@lists_path + @exceptions_list, 'w')
  text = File.read(filename)
  @hash2 = Hash.new(0)
  text.split.inject(@hash2) { |h, v| h[v] += 1; h }
  @letter_counter = '@'
  @hash2.sort.each do |key, value|
    key = key.gsub(/:|;|,|\.|!|¡|—|-/, "")
    @the_first = key[0]
    @letter_counter = 'a' if @the_first != @the_next

    open(@lists_path + @exceptions_list, 'a') { |f| f.puts key.to_s } if key.length <= 3
    open(@lists_path + @the_first.downcase + @lists_name, 'a') do |f|
      f.puts "#{@the_first}#{@letter_counter} " + key.to_s if key.length > 3
    end
    @letter_counter = @letter_counter.next
    @the_next = key[0]
  end
  puts ' Imported file: '.ljust(22).blue + "\"#{filename}\"".to_s
  puts ' Folder with lists: '.ljust(22).blue + "\"#{@lists_path}\"".to_s
  print  "\n Finished, now you can encode a file...\n"
end

def list_to_hash(filename)
  @hash = Hash.new(0)
  File.open(filename) do |fp|
    fp.each do |line|
      key, value = line.chomp.split("\s")
      @hash[key] = value
    end
  end
end

def encode_file(filename)
  encoded_word = ''
  print "\n Processing coding: \n\n"
  File.open(filename) do |fp|
    fp.read.scan(/[[:alpha:]](?:(?:[[:alpha:]]|\d|'|-)*[[:alpha:]])?/) do |word|
      # fp.read.scan(/(\b\w+\b|\W+)/) do |word|
      if word.length <= 3
        # print word.downcase + " "
        encoded_word = encoded_word + word.downcase + ' '
      elsif word.length > 3
        @first_initial = word[0]
        if !Dir.glob(@lists_path + @first_initial.downcase + '*').empty?
          list_to_hash @lists_path + @first_initial.downcase + @lists_name
            if @hash.value?(word)
              # print @hash.key(word) + " "
              encoded_word = encoded_word +  @hash.key(word) + ' '
            else
              # print word.downcase + " "
              encoded_word = encoded_word +  word.downcase + ' '
            end
        else
          # print word.downcase + " "
          encoded_word = encoded_word + word.downcase + ' '
        end
      end
    end
  end

  File.open('encoded.txt', 'w') { |file| file.puts encoded_word }
  # puts encoded_word
  original_file_size = File.size(filename)
  encoded_file_size = File.size('encoded.txt')
  puts ' Original File: '.red
  puts ' Directory: '.ljust(22).yellow + "\"#{filename}\"".to_s
  puts ' Size: '.ljust(22).yellow + format_mb(original_file_size)
  puts
  puts ' Encoded File : '.red
  puts ' Directory: '.ljust(22).yellow + File.expand_path('encoded.txt').to_s
  puts ' Size: '.ljust(22).yellow + format_mb(encoded_file_size)
end

def format_mb(size)
  conv = %w[b kb mb gb tb pb eb]
  scale = 1024
  ndx = 1
  return "#{size} #{conv[ndx - 1]}" if size < 2 * (scale**ndx)

  size = size.to_f
  [2, 3, 4, 5, 6, 7].each do |ndx|
    return "#{'%.3f' % (size / (scale**(ndx - 1)))} #{conv[ndx - 1]}" if size < 2 * (scale**ndx)

  end

  ndx = 7
  return "#{'%.3f' % (size / (scale**(ndx - 1)))} #{conv[ndx - 1]}"
end

def decode_file(filename)
  print "\n Processing decoding: \n\n"
  File.open(filename) do |fp|
    fp.read.scan(/[[:alpha:]](?:(?:[[:alpha:]]|\d|')*[[:alpha:]])?/) do |word|
      @first_initial = word[0]
      search_word(@lists_path + @exceptions_list, word)
      if @status_found == true
        print @word_value + ' '
      elsif !Dir.glob(@lists_path + @first_initial.downcase + @lists_name).empty?
        list_to_hash @lists_path + @first_initial.downcase + @lists_name
        if @hash.key?(word)
          print @hash[word] + ' '
        else
          print word + ' '
        end
      end
    end
  end
  # puts
end

def search_word(file_list, the_word)
  filter = the_word
  File.foreach(file_list) do |line|
    if line.strip == filter
      @word_value = line.strip
      @status_found = true
      break
    else
      @status_found = false
    end
  end
end

def read_file(filename)
  puts "\n" + ' ' + ' READING: '.center(54, '#').yellow
  puts ' ' + filename.to_s.dark_green
  puts ' ' + ' BEGINNING OF FILE '.center(54, '#').yellow
  File.open(filename).each do |line|
    puts line.rstrip.to_s
  end
  puts ' ' + ' END OF FILE '.center(54, '#').yellow
end

def read_file_with_n(filename)
  puts "\n" + ' ' + ' READING: '.center(54, '#').yellow
  puts ' ' + filename.to_s.dark_green
  puts ' ' + ''.center(54, '#').yellow
  puts
  puts 'LINE: '.ljust(5).yellow + 'TEXT:'.yellow
  File.open(filename).each do |line|
    puts $..to_s.ljust(5, '.').yellow + ':'.yellow + line.rstrip.to_s
  end
  puts ' ' + ' END OF FILE '.center(54, '#').yellow
end

options = {}
OptionParser.new do |opts|
  opts.banner = "\n Usage mode: ruby shortening.rb [options] [arguments...]".yellow
  opts.separator ''
  opts.version = '0.1'
  opts.on('-m', '--make LISTS', 'Make file lists.') do |makelists|
    options[:makelists] = makelists
    @base_list = options[:makelists].to_s
    list_maker @base_list
  end
  opts.on('-e', '--encode FILE', 'Encode file.') do |encode|
    options[:encode] = encode
    @file_to_encode = options[:encode].to_s
    encode_file @file_to_encode
  end
  opts.on('-d', '--decode FILE', "Decode file.\n") do |decode|
    options[:decode] = decode
    @file_to_decode = options[:decode].to_s
    decode_file @file_to_decode
  end
  opts.on('-r', '--read FILE', "Read a text file.\n") do |readtextfile|
    options[:readtextfile] = readtextfile
    @file_to_read = options[:readtextfile].to_s
    read_file @file_to_read
  end
  opts.on('-n', '--numberlines FILE', "Read a text file with line numbers.\n") do |readtextfile2|
    options[:readtextfile2] = readtextfile2
    @file_to_read_with_n = options[:readtextfile2].to_s
    read_file_with_n @file_to_read_with_n
  end
  opts.on('-h', '--help', "Displays help.\n\n") do
    puts opts
    exit
  end
  if ARGV.empty?
    puts opts.on
    exit 1
  end
  begin
    opts.parse!
  rescue OptionParser::ParseError => e
    puts "\n [!] #{e}\n [!] -h or --help to show valid options.\n\n"
    exit 1
  end
end.parse!
puts
