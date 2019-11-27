# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'English'

@config_file = Dir.home.to_s + '/config.yml'
@first_initial = ''
CLEAR = "\e[H\e[2J"

def load_configuration
  config = YAML.load_file(@config_file)
  @lists_path = config[:lists_path]
  @lists_name = config[:lists_name]
  @exceptions_list = config[:exceptions_list]
  @word_reduction_list = config[:word_reduction_list]
end

if File.file?(@config_file)
  load_configuration
else
  recipe = { lists_path: Dir.home.to_s + '/lists/', lists_name: '_list.txt', exceptions_list: 'exceptions.txt', word_reduction_list: 'reduction_list.txt' }
  File.open('config.yml', 'w') { |file| file.write(recipe.to_yaml) }
  load_configuration
end

puts ::CLEAR
puts ' ' + ' SHORTENING V0.1 '.center(54, '=')
puts ' (for now it works only with plain text files)'
puts ' Configuration file: '.ljust(22) + "\"#{@config_file}\"".to_s
puts ' Lists directory: '.ljust(22) + "\"#{@lists_path}\"".to_s
puts ' ' + ' By Jonathan Burgos '.center(54, '=')

def list_maker(filename)
  print "\n Processing file: \n\n"
  system('rm -rf ' + @lists_path + '*')
  system('mkdir -p ' + @lists_path)
  File.new(@lists_path + @exceptions_list, 'w')
  text = File.read(filename)
  @hash2 = Hash.new(0)
  text.split.each_with_object(@hash2) { |v, h| h[v] += 1; }
  @letter_counter = '@'
  @hash2.sort.each do |key, _value|
    @the_first = key[0]
    @letter_counter = 'a' if @the_first != @the_next

    if key.length <= 3
      open(@lists_path + @exceptions_list, 'a') { |f| f.puts key.to_s }
    end
    open(@lists_path + @the_first.downcase + @lists_name, 'a') do |f|
      # check si tiene letras repetidas
      reps = detect_repetitions(key)
      if reps == true
        word = key.gsub(/(.)\1+/) { |x| "#{Regexp.last_match(1)}#{x.size}" }
        open(@lists_path + @word_reduction_list, 'a') { |f| f.puts word.to_s }
      end
      f.puts "#{@the_first}#{@letter_counter} " + key.to_s if key.length > 3
    end
    @letter_counter = @letter_counter.next
    @the_next = key[0]
  end
  puts ' Imported file: '.ljust(22) + "\"#{filename}\"".to_s
  puts ' Folder with lists: '.ljust(22) + "\"#{@lists_path}\"".to_s
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
  print "\n Encoding: \n\n"
  File.open(filename) do |fp|
    fp.read.scan(%r{\w+(?:0[1-9]|[1-9]\d)\d|[\d|[:alpha:]](?:(?:[[:alpha:]])*[[:alpha:]])?|\n|\s|'|-|\.|:|/|\.\s|\`|\W|0}) do |word|
      reps = detect_repetitions(word)
      if reps == true
        encode_repetitions(word, true)
        word = word.gsub(/(.)\1+/) { |x| "#{Regexp.last_match(1)}#{x.size}" }
        encoded_word += word
      elsif word =~ /^\d{3}.*$/
        @first_initial = word[0]
        if !Dir.glob(@lists_path + @first_initial + '*').empty?
          list_to_hash @lists_path + @first_initial + @lists_name
          encoded_word = if @hash.value?(word)
                           encoded_word + @hash.key(word)
                         else
                           encoded_word + word.to_s
                         end
        else
          encoded_word += word
        end
      elsif word.length <= 3
        # print word.downcase + " "
        encoded_word += word
      elsif word.length > 3
        @first_initial = word[0].downcase
        if !Dir.glob(@lists_path + @first_initial + '*').empty?
          list_to_hash @lists_path + @first_initial + @lists_name
          encoded_word = if @hash.value?(word)
                           # print @hash.key(word) + " "
                           encoded_word + @hash.key(word)
                         else
                           # print word.downcase + " "
                           encoded_word + word
                         end
        else
          # print word.downcase + " "
          encoded_word += word
        end
      end
    end
  end

  File.open('encoded.txt', 'w') { |file| file.puts encoded_word }
  encoded_word = encoded_word.gsub!(/\r\n?/, "\n")
  original_file_size = File.size(filename)
  encoded_file_size = File.size('encoded.txt')
  puts ' Original file: '
  puts ' Directory: '.ljust(22) + "\"#{filename}\"".to_s
  puts ' Size: '.ljust(22) + format_mb(original_file_size)
  puts
  puts ' Encoded file : '
  puts ' Directory: '.ljust(22) + File.expand_path('encoded.txt').to_s
  puts ' Size: '.ljust(22) + format_mb(encoded_file_size)
end

def decode_file(filename)
  decoded_word = ''
  print "\n Decoding: \n\n"
  File.open(filename) do |fp| fp.read.scan(%r{\w+(?:0[1-9]|[1-9]\d)\d|[\d|[:alpha:]](?:(?:[[:alpha:]])*[[:alpha:]])?|\n|\s|'|-|\.|:|/|\.\s|\`|\W|0}) do |word|
      @first_initial = word[0]
      search_word(@lists_path + @word_reduction_list, word)
      if @status_found == true
        encode_repetitions(word, false)
        decoded_word += @whole_word + ' '
        next
      end
      search_word(@lists_path + @exceptions_list, word)
      if @status_found == true
        decoded_word += @word_value + ' '
      elsif !Dir.glob(@lists_path + @first_initial.downcase + \
        @lists_name).empty?
        list_to_hash @lists_path + @first_initial.downcase + @lists_name
        decoded_word = if @hash.key?(word)
                         decoded_word + @hash[word] + ' '
                       else
                         decoded_word + word + ' '
                       end
      elsif word =~ /\n/
        decoded_word +=   "\n"
      elsif word =~ /\d+|\W+/
        decoded_word +=   word
      end
    end
  end
  File.open('decoded.txt', 'w') { |file| file.puts decoded_word }
  puts ' Original file: '.ljust(22) + filename.to_s
  puts ' Decoded file: '.ljust(22) + File.expand_path('decoded.txt').to_s
end

def format_mb(size)
  conv = %w[b kb mb gb tb pb eb]
  scale = 1024
  ndx = 1
  return "#{size} #{conv[ndx - 1]}" if size < 2 * (scale**ndx)
  size = size.to_f
  [2, 3, 4, 5, 6, 7].each do |ndx|
    if size < 2 * (scale**ndx)
      return "#{format('%.3f', (size / (scale**(ndx - 1))))} #{conv[ndx - 1]}"
    end
  end
  ndx = 7
  "#{format('%.3f', (size / (scale**(ndx - 1))))} #{conv[ndx - 1]}"
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

def read_file_with_n(filename)
  puts "\n" + ' ' + ' READING: '.center(54, '#')
  puts ' ' + filename.to_s
  puts ' ' + ''.center(54, '#')
  puts
  puts 'LINE: '.ljust(5) + 'TEXT:'
  File.open(filename).each do |line|
    puts $INPUT_LINE_NUMBER.to_s.ljust(5, '.') + ':' + line.rstrip.to_s
  end
  puts ' ' + ' END OF FILE '.center(54, '#')
end

def detect_repetitions(the_word)
  reduced = the_word.split('')
  total = reduced.length - 1
  sum_repeated_letters = 0
  (0..total).each do |i|
    the_next = i + 1
    if reduced[i] == reduced[the_next]
      sum_repeated_letters += 1
    else
      next
    end
  end
  sum_repeated_letters.to_i > 3
end

def encode_repetitions(string, compress)
  @whole_word = ''
  @reduced = ''
  @reduced2 = ''
  translated = ''
  @reduced = string.gsub(/(.)\1+/) { |x| "#{Regexp.last_match(1)}#{x.size}" }
  if compress == true
  elsif compress == false
    @reduced2 = string
    start_counter = 0
    total = @reduced2.length - 1
    (start_counter..total).each do |i|
      the_next = i + 1
      if /\d/.match(@reduced2[i])
        next
      elsif /\d/.match(@reduced2[the_next])
        n_repetitions = @reduced2[the_next].to_i
        translated = @reduced2[i] * n_repetitions
        @whole_word += translated
      else
        translated = @reduced2[i]
        translated = translated.to_s
        @whole_word += translated
      end
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "\n Usage mode: ruby shortening.rb [options] [arguments...]"
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
  opts.on('-n', '--numberlines FILE', "Read a text file with line numbers.\n") \
  do |readtextfile2|
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
