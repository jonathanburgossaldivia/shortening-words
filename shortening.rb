require 'optparse'
require 'yaml'

@config_file = "#{Dir.home}/config.yml"
@primera_inicial = ""
@codificado= ""

class String #reciclado

    def red; colorize(self, "\e[1m\e[31m"); end
    def green; colorize(self, "\e[1m\e[32m"); end
    def dark_green; colorize(self, "\e[32m"); end
    def yellow; colorize(self, "\e[1m\e[33m"); end
    def blue; colorize(self, "\e[1m\e[34m"); end
    def dark_blue; colorize(self, "\e[34m"); end
    def pur; colorize(self, "\e[1m\e[35m"); end

    def colorize(text, color_code)  
    	"#{color_code}#{text}\e[0m"
    end

end

def cargar_configuracion()
	config = YAML.load_file(@config_file)
	@ruta_listas = config[:'ruta_listas']
	#puts @ruta_listas
	@nombre_listas = config[:'nombre_listas']
	#puts @nombre_listas
	@lista_de_excepciones = config[:'lista_de_excepciones']
	#puts @lista_de_excepciones
end

if  (File.file?(@config_file))
	cargar_configuracion()
else
	recipe =  { ruta_listas: "#{Dir.home}/lists/",
	nombre_listas: "_list.txt", 
	lista_de_excepciones: "exceptions.txt" }
	File.open("config.yml", "w") { |file| file.write(recipe.to_yaml) }
	cargar_configuracion()
end

def banner()
	puts "\e[H\e[2J"
	puts " " + "banner".center(54, "#")
	puts " Configuration file: ".ljust(22).green +  "\"#{@config_file}\"".to_s
	puts " Lists directory: ".ljust(22).green + "\"#{@ruta_listas}\"".to_s
	puts " " + "==".center(54, "#")
end

banner()

def creador_listas(filename)

	print "\n Processing file: \n\n".yellow
	
	system("rm -rf " + @ruta_listas+ "*" )
	system("mkdir -p " + @ruta_listas)
	File.new(@ruta_listas + @lista_de_excepciones, "w")
	text = File.read(filename)

	@hash2 = Hash.new(0)
	text.split.inject(@hash2) { |h,v| h[v] += 1; h }

	@contador_letra = "@"
	@hash2.sort.each do |key, value|

		key = key.gsub(/:|;|,|\.|!|¡|—|-/,"")

		@mi_inicial = key[0]

		if @mi_inicial != @mi_inicial2
			@contador_letra = "a"
		end

		if key.length <= 3
			open(@ruta_listas + @lista_de_excepciones, 'a') { |f|
  				f.puts "#{key}"
			}
		end

		open(@ruta_listas+@mi_inicial.downcase + @nombre_listas, 'a') do |f|
			f.puts "#{@mi_inicial}#{@contador_letra} #{key}" if key.length > 3
		end

		@contador_letra = @contador_letra.next
		@mi_inicial2 = key[0]

	end
	puts " Imported file: ".ljust(22).blue + "\"#{filename}\"".to_s
	puts " Folder with lists: ".ljust(22).blue + "\"#{@ruta_listas}\"".to_s
	print  "\n Finished, now you can encode a file...\n"

end

def lista_a_hash(filename)

	@hash = Hash.new(0)
	File.open(filename) do |fp|

		fp.each do |line|
			key, value = line.chomp.split("\s")
			@hash[key] = value
		end

	end

end

def codificar(filename)

	print "\n Processing coding: \n\n"

	File.open(filename) do |fp|

		fp.read.scan(/[[:alpha:]](?:(?:[[:alpha:]]|\d|'|-)*[[:alpha:]])?/) do |word|
		#fp.read.scan(/(\b\w+\b|\W+)/) do |word|

			if word.length <=3
				#print word.downcase + " "
				@codificado = @codificado +  word.downcase + " "
			elsif word.length > 3
				@primera_inicial = word[0]

				if !Dir.glob(@ruta_listas + @primera_inicial.downcase + '*').empty?
					lista_a_hash @ruta_listas + @primera_inicial.downcase + @nombre_listas

					if @hash.has_value?(word) 
						#print @hash.key(word) + " "
						@codificado = @codificado +  @hash.key(word) + " "
					else
						#print word.downcase + " "
						@codificado = @codificado +  word.downcase + " "
					end

				else
					#print word.downcase + " "
					@codificado = @codificado +  word.downcase + " "
				end

			end

		end

	end

	File.open("encoded.txt", "w") { |file| file.puts @codificado}
	#puts @codificado
	mb_archivo_original = File.size(filename)
	mb_archivo_codificado = File.size("encoded.txt")

	puts " Original File: ".red
	puts " Directory: ".ljust(22).yellow + "\"#{filename}\"".to_s
	puts " Size: ".ljust(22).yellow + format_mb(mb_archivo_original)
	puts
	puts " Encoded File : ".red
	puts " Directory: ".ljust(22).yellow + File.expand_path('encoded.txt').to_s
	puts " Size: ".ljust(22).yellow + format_mb(mb_archivo_codificado)

end

def format_mb(size) #reciclado

	conv = [ 'b', 'kb', 'mb', 'gb', 'tb', 'pb', 'eb' ];
	scale = 1024;

	ndx=1

	if( size < 2*(scale**ndx)  ) then
		return "#{(size)} #{conv[ndx-1]}"
	end

	size=size.to_f

	[2,3,4,5,6,7].each do |ndx|

    	if( size < 2*(scale**ndx)  ) then
			return "#{'%.3f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
		end

	end

	ndx=7
	return "#{'%.3f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"

end

def decodificar(filename)

	print "\n Processing decoding: \n\n"

	File.open(filename) do |fp|

		fp.read.scan(/[[:alpha:]](?:(?:[[:alpha:]]|\d|')*[[:alpha:]])?/) do |word|

			@primera_inicial = word[0]
			buscar_palabra(@ruta_listas + @lista_de_excepciones,word)

			if @estatus_econtrado == true
				print @valor_palabra + " "
			elsif !Dir.glob(@ruta_listas + @primera_inicial.downcase + @nombre_listas).empty?
				lista_a_hash @ruta_listas + @primera_inicial.downcase + @nombre_listas
				
				if @hash.has_key?(word)
					print @hash[word] + " "
				else
					print word + " "
				end

			end

		end

	end

	#puts

end

def buscar_palabra(lista_archivo,la_palabra)

	filter=la_palabra
	File.foreach(lista_archivo).with_index do |line, line_num|

		if line.strip == filter
			@valor_palabra = line.strip
			@estatus_econtrado = true
			break
		else
   			@estatus_econtrado = false
   		end

	end

end

def leerarchivo(filename)
	puts "\n" + " " + " READING: ".center(54, "#").yellow
	puts " " + "#{filename}".dark_green
	puts " " + " BEGINNING OF FILE ".center(54, "#").yellow
	File.open(filename).each do |line|
		puts "#{line.rstrip}"
	end
	puts " " + " END OF FILE ".center(54, "#").yellow
end

def leerarchivo2(filename)
	puts "\n" + " " + " READING: ".center(54, "#").yellow
	puts " " + "#{filename}".dark_green
	puts " " + "".center(54, "#").yellow
	puts
	puts "LINE: ".ljust(5).yellow + "TEXT:".yellow
	File.open(filename).each do |line|
		puts "#{$.}".ljust(5, ".").yellow + ":".yellow + "#{line.rstrip}"
	end
	puts " " + " END OF FILE ".center(54, "#").yellow
end

options = {}

OptionParser.new do |opts|
	opts.banner = "\n Usage mode: ruby shortening.rb [options] [arguments...]".yellow
	opts.separator ""
	opts.version = "0.1"
	opts.on('-m', '--make LISTS', 'Make file lists.') do |makelists|
		options[:makelists] = makelists;
		@lista_base = options[:makelists].to_s
		creador_listas @lista_base
	end
	opts.on('-e', '--encode FILE', 'Encode file.') do |encode|
		options[:encode] = encode;
		@archivo_codificar = options[:encode].to_s
		codificar @archivo_codificar
	end
	opts.on('-d', '--decode FILE', "Decode file.\n") do |decode|
		options[:decode] = decode;
		@archivo_decodificar = options[:decode].to_s
		decodificar @archivo_decodificar
	end
	opts.on('-r', '--read FILEnumbers', "Read a text file.\n") do |readtextfile|
		options[:readtextfile] = readtextfile;
		@leeryaml = options[:readtextfile].to_s
		leerarchivo @leeryaml
	end
	opts.on('-n', '--readfile FILE', "Read a text file with line numbers.\n") do |readtextfile2|
		options[:readtextfile2] = readtextfile2;
		@leeryaml2 = options[:readtextfile2].to_s
		leerarchivo2 @leeryaml2
	end
	opts.on("-h", "--help", "Displays help.\n\n") do
    	puts opts
    	exit
  	end

	if ARGV.empty?
		puts opts.on
		exit 1
	end

	begin
		opts.parse!
	rescue OptionParser::ParseError => error
		puts "\n [!] #{error}\n [!] -h or --help to show valid options.\n\n"
		exit 1
	end
end.parse!

puts