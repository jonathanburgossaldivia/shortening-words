# Word shortener

Word shortener, created to reduce disk space, this program creates a list of files with the shortened words next to the original words, with this you can encode a file and create a file with a smaller file size and can "compress" many more Files with this list, with this program you can reduce storage space by half or less

### Prerequisites

Requires macOS or Linux operating system.

### How to use

ruby shortening.rb [options] [arguments...]

Available options: make file, encode or decode a file, read a file with line numbers. 

```
ruby shortening.rb [options] [arguments...]
```

For example if you want to create a new word list from a file and save them in a folder configured in the Yaml file, by default created in the home folder:

```
ruby shortening.rb -m file_to_make_lists.txt
```

If you want to encode a file with the created list you must execute::

```
ruby shortening.rb -e file_to_encode.txt
```

If you want to decode a file with the created list you must execute:

```
ruby shortening.rb -d file_to_decode.txt
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

