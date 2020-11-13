
require 'aws-sdk-ses'
require 'aws-sdk-s3'
require 'base64'

class AwsController

  $bucket = 'foodmanagement23'

  $s3 = Aws::S3::Client.new(
    :access_key_id     => ENV['aws_access_key_id'],
    :secret_access_key => ENV['aws_secret_access_key'],
    :session_token => ENV['aws_session_token']
  )

  def self.upload(params)
    begin
      id = params['id']
      file = params[:file][:tempfile]
      filename = "item#{id}.JPG"
      $s3.put_object(bucket: $bucket, key: filename, body: file)
    rescue => exception
      puts "image not uploaded"
    end
  end

  def self.uploadnew(id, params)
    begin
      file = params[:file][:tempfile]
      filename = "item#{id}.JPG"
      $s3.put_object(bucket: $bucket, key: filename, body: file)
    rescue => exception
      puts "image not uploaded"
    end
  end

  def self.getimage(id)
    begin
      image = $s3.get_object({
        bucket: $bucket, 
        key: "item#{id}.JPG"
      })
    rescue => exception
      image = $s3.get_object({
        bucket: "foodmanagement23", 
        key: "noimage.jpg"
      })
    end
    base64 = Base64.encode64(image.body.string)
    base64 
  end

  def self.delete(id)
    begin
      $s3.delete_object(bucket: $bucket, key: "item#{id}.JPG" )
    rescue => exception
      puts "image not uploaded"
    end
  end

end



