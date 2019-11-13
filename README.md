# Word shortener

Word shortener, created to reduce disk space by encoding plain text files, this program creates a list of files with the shortened words next to the original words, with this you can encode a file and create a file with a smaller file size and can "compress" many more files with this list, with this program you can reduce storage space to half or less.

### Prerequisites

Requires macOS or Linux operating system.

### How to use

Shortening has several ways of using, available options: make file, encode or decode a file, read a file with line numbers. 

Method of usage from the command line:

```
ruby shortening.rb [options] [arguments...]
```

If you want to create a new word list from a file and save them in a folder configured in the Yaml file, this folder by default is created in the home folder:

```
ruby shortening.rb -m file_to_make_lists.txt
```

If you want to encode a file with the created list you must execute:

```
ruby shortening.rb -e file_to_encode.txt
```

If you want to decode a file:

```
ruby shortening.rb -d file_to_decode.txt
```

Or if you want to read a file showing the number corresponding to the lines:

```
ruby shortening.rb -n file_to_read.txt
```

### THINGS TO DO

- Compatibility with CRLF line terminators
- Codify new lines, carriage returns, among others.

## Built With

* [Sublime Text 3](https://www.sublimetext.com) - More than a simple text editor.

## Authors

* **Jonathan Burgos** - *Initial work*

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* To Ruby-forum
