require 'spec_helper'
require 'easy-s3'
require 'fog'

describe EasyS3 do
  let(:bucket_name)             { 'my-bucket' }
  let(:bucket_not_exist_name)   { 'test' }
  let(:region)                  { 'eu-west-1' }
  let(:s3)                      { EasyS3.new(bucket_name) }
  let(:file_path)               { File.join('spec', 'support', 'file.txt') }
  let(:file_not_exist_path)     { File.join('spec', 'support', 'file_not_exist.txt') }

  before :all do
    Fog.mock!
    Fog.credentials = { aws_access_key_id: 'XXX', aws_secret_access_key: 'XXXX' , region: 'eu-west-1' }
    connection = Fog::Storage.new(provider: 'AWS')
    connection.directories.create(key: 'my-bucket')
  end

  context '.initialize' do
    it 'should raise exception if call method without argument directory name' do
      expect{ EasyS3.new }.to raise_error(ArgumentError, 'wrong number of arguments (0 for 1..2)')
    end

    it 'should accept options hash as the second argument' do
      Fog.credentials = {}
      EasyS3.new(bucket_name, access_key_id: 'XXX', secret_access_key: 'XXXX', region: 'eu-west-1').should be_an_instance_of EasyS3
    end

    it 'should raise exception if missing options access_key_id or secret_access_key' do
      fog_credentials = Fog.credentials
      Fog.credentials = {}
      expect{ s3 }.to raise_error(EasyS3::MissingOptions, 'access_key_id or secret_access_key')
      Fog.credentials = fog_credentials
    end

    it 'should raise exception if directory does not exist' do
      expect{ EasyS3.new(bucket_not_exist_name) }.to raise_error(EasyS3::DirectoryDoesNotExist, bucket_not_exist_name)
    end

    it 'should return true and instance of EasyS3' do
      s3.should be_an_instance_of EasyS3
    end
  end

  context '#create_file' do
    it 'should raise exception if file not found' do
      expect{ s3.create_file(file_not_exist_path) }.to raise_error(EasyS3::FileNotFound, file_not_exist_path)
    end

    it 'should create file with digest' do
      url = s3.create_file(file_path, digest: true, public: true)
      url.should match Digest::SHA1.hexdigest(File.basename(file_path))
    end

    it 'should create a public file' do
      url = s3.create_file(file_path, public: true)
      url.should be_an_instance_of String
      url.should_not match /#{bucket_name}.+amazonaws.com.+AWSAccessKeyId=#{Fog.credentials[:aws_access_key_id]}/
    end

    it 'should create a private file' do
      url = s3.create_file(file_path)
      url.should be_an_instance_of String
      url.should match /#{bucket_name}.+amazonaws.com.+X-Amz-Credential=#{Fog.credentials[:aws_access_key_id]}/
    end
  end

  context '#get_file_name_by_url' do
    it 'should return name of file by url' do
      url = s3.create_file(file_path)
      s3.send(:get_filename_by_url, url).should eq "#{File.basename(file_path)}"
    end
  end

  context '#delete_file' do
    it 'should return false if file not found on Amazon S3' do
      s3.delete_file('bad_file').should be_falsey
    end

    it 'should delete file by namea and return true' do
      url = s3.create_file(file_path)
      s3.delete_file(url).should be_truthy
    end
  end

  context '#files' do
    it 'should return instance of Fog::Storage::AWS::Files' do
      s3.files.should be_an_instance_of Fog::Storage::AWS::Files
    end
  end
end