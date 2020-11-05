
require 'aws-sdk-ses'
require 'aws-sdk-s3'
require 'base64'

class AwsController
  $awskey = ENV['AWS_KEY']
  $awssecret = ENV['AWS_SECRET']
  $awstoken = ENV['AWS_TOKEN']
  $bucket = 'foodmanagement23'

  $s3 = Aws::S3::Client.new(
    :access_key_id     => $awskey,
    :secret_access_key => $awssecret,
    :session_token => $awstoken
  )

  def upload(params)
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

  def self.getimage(id, pointer)
    begin
      image = $s3.get_object({
        bucket: "foodmanagement23", 
        key: "item#{id}.JPG"
      })
    rescue => exception
      image = $s3.get_object({
        bucket: "foodmanagement23", 
        key: "noimage.jpg"
      })
    end
    base64 = Base64.encode64(image.body.string)
    if pointer == 1 
      return "<img src ='data:image/jpeg;base64,#{base64}' height='70' width='70' class='center'>"
    else
      return "<img src ='data:image/jpeg;base64,#{base64}' height='200' width='200' class='center'>"
    end
  end

  def self.delete(id)
    begin
      $s3.delete_object(bucket: $bucket, key: "item#{id}.JPG" )
    rescue => exception
      puts "image not uploaded"
    end
  end

end



