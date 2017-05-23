s3_config = Rails.application.secrets.s3

$s3 = if Rails.application.secrets.s3.present?
  Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id: s3_config.fetch("access_key"),
    aws_secret_access_key: s3_config.fetch("secret_key"),
    region: s3_config.fetch("region")
  )
else
  raise "S3 configuration missing from config/secrets.yml.\n See config/secrets.yml.example"
end
