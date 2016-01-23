require 'fog'
require 'easy-s3/version'

class EasyS3
  MissingOptions        = Class.new(StandardError)
  DirectoryDoesNotExist = Class.new(StandardError)
  FileNotFound          = Class.new(StandardError)

  attr_reader :fog, :dir

  def initialize(dir_name, options={})
    options[:access_key_id]     ||= Fog.credentials[:aws_access_key_id]
    options[:secret_access_key] ||= Fog.credentials[:aws_secret_access_key]
    options[:region]            ||= Fog.credentials[:region]

    Fog.credentials = {
        aws_access_key_id:      options[:access_key_id],
        aws_secret_access_key:  options[:secret_access_key],
        region:                 options[:region]
    }

    begin
      @fog = Fog::Storage.new(provider: 'AWS')
      @dir = @fog.directories.get(dir_name)
    rescue ArgumentError
      fail MissingOptions, 'access_key_id or secret_access_key'
    rescue Excon::Errors::MovedPermanently, 'Expected(200) <=> Actual(301 Moved Permanently)'
      fail DirectoryDoesNotExist, dir_name
    end
    fail DirectoryDoesNotExist, dir_name if @dir.nil?

    true
  end

  # Create private or public file into directory
  def create_file(file_path, options={})
    options[:digest] ||= false
    options[:public] ||= false

    file      = File.open(file_path)
    extension = File.extname(file_path)
    filename  = File.basename(file_path, extension)
    filename  += "_#{Digest::SHA1.hexdigest(File.basename(file_path))}" if options[:digest]
    filename  += extension

    file = @dir.files.create(
        key:    filename,
        body:   file,
        public: options[:public]
    )

    return file.public_url if options[:public] && file.public_url

    file.url((Time.now + 3600).to_i) # 1 hour
  rescue
    fail FileNotFound, file_path
  end

  # Delete file by url
  def delete_file(url)
    file_name = get_filename_by_url(url)
    return false unless @dir.files.head(file_name)
    @dir.files.get(file_name).destroy
  end

  # Get all files into directory
  def files
    @dir.files.all
  end

  private

  def get_filename_by_url(url)
    File.basename(URI(url).path)
  end
end