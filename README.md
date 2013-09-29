# EasyS3

Easy use Amazon S3

## Installation

Add this line to your application's Gemfile:

    gem 'easy-s3'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy-s3

## Usage

First, set the credentials for Fog:

    Fog.credentials = {
      aws_access_key_id: 'XXX',
      aws_secret_access_key: 'XXXX'
    }

Create instance of EasyS3:

    s3 = EasyS3.new('my-bucket')
    
Create private or public file:

    file_url = s3.create_file(path_to_file) # private
    file_url = s3.create_file(path_to_file, true) # public
    
Delete file by url:

    file_url = s3.create_file(path_to_file)
    s3.delete_file(file_url)
    
Get all files in bucket:

    s3.files

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
