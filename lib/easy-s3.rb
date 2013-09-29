require 'fog'
require 'easy-s3/version'

class EasyS3
  class MissingOptions < StandardError; end
  class DirectoryDoesNotExist < StandardError; end
  class FileNotFound < StandardError; end

  attr_reader :fog, :dir

  def initialize(dir_name)
    begin
      #Fog.credentials = { aws_access_key_id: 'XXX', aws_secret_access_key: 'XXXX' }
      @fog = Fog::Storage.new(provider: 'AWS')
      @dir = @fog.directories.get(dir_name)
    rescue ArgumentError
      raise MissingOptions, 'aws_access_key_id or aws_secret_access_key'
    rescue Excon::Errors::MovedPermanently, 'Expected(200) <=> Actual(301 Moved Permanently)'
      raise DirectoryDoesNotExist, dir_name
    end
    raise DirectoryDoesNotExist, dir_name if @dir.nil?

    true
  end

  # Create private or public file into directory
  def create_file(file_path, public = false)
    begin
      file = File.open(file_path)
    rescue
      raise(FileNotFound, file_path)
    end

    filename = "#{File.basename(file_path)}_#{Digest::SHA1.hexdigest(File.basename(file_path))}"

    file = @dir.files.create(
        key:    filename,
        body:   file,
        public: public
    )
    file.url((Time.now + 3600).to_i) # 1 hour
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
