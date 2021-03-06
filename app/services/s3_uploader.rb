class S3Uploader
  UPLOAD_TTL = 30.minutes
  FILE_TYPES = {
    png:  { mime: 'image/png',  ext: 'png' },
    jpg:  { mime: 'image/jpeg', ext: 'jpg' },
    jpeg: { mime: 'image/jpeg', ext: 'jpg' },
    gif:  { mime: 'image/gif',  ext: 'gif' }
  }

  attr_reader :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def key
    unique_hash = Digest::SHA1.hexdigest("uploads#{SecureRandom.uuid}#{Rails.env}")
    @key ||= "uploads/#{unique_hash[0..1]}/#{unique_hash}---#{base_name}.#{file_ext}"
  end

  def url
    @signed_url ||= $s3.put_object_url(bucket, key, Time.current.utc + UPLOAD_TTL, {
      'x-amz-acl' => 'public-read',
      'Content-Type' => mime
    })
  end

  def base_url
    if cloudfront
      "https://#{cloudfront}.cloudfront.net/#{key}"
    else
      "https://#{bucket}.s3.amazonaws.com/#{key}"
    end
  end

  def file_type
    return unless file_name
    FILE_TYPES[File.extname(file_name).sub('.','').downcase.to_sym]
  end

  def base_name
    File.basename(file_name, ".*")
  end

  def mime
    file_type && file_type[:mime]
  end

  def file_ext
    file_type && file_type[:ext]
  end

  def valid?
    !!file_type
  end

  private

  def bucket
    Rails.application.secrets.s3['bucket']
  end

  def cloudfront
    Rails.application.secrets.s3['cloudfront']
  end

end
