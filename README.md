# EasyS3

Easy use Amazon S3

[![Build Status](https://travis-ci.org/mgrachev/easy-s3.png?branch=master)](https://travis-ci.org/mgrachev/easy-s3)
[![Coverage Status](https://coveralls.io/repos/mgrachev/easy-s3/badge.png?branch=master)](https://coveralls.io/r/mgrachev/easy-s3?branch=master)
[![Dependency Status](https://gemnasium.com/mgrachev/easy-s3.png)](https://gemnasium.com/mgrachev/easy-s3)

## Installation

Add this line to your application's Gemfile:

    gem 'easy-s3'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy-s3

## Usage

Create an instance of EasyS3:

    s3 = EasyS3.new('my-bucket', access_key_id: 'XXX', secret_access_key: 'XXXX', region: 'eu-west-1')
    
Create a private or a public file:

    file_url = s3.create_file(path_to_file) # private
    file_url = s3.create_file(path_to_file, public: true) # public
    file_url = s3.create_file(path_to_file, digest: true) # with digest
    
Delete a file by url:

    file_url = s3.create_file(path_to_file)
    s3.delete_file(file_url)
    
Get all files in the bucket:

    s3.files

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
