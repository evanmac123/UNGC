$s3 = Fog::Storage.new(
                       :provider => 'AWS',
                       :aws_access_key_id => Rails.application.secrets.s3["access_key"],
                       :aws_secret_access_key => Rails.application.secrets.s3["secret_key"],
                       :region => Rails.application.secrets.s3['region']
                      )

$s3_bucket = $s3.directories.get(Rails.application.secrets.s3['bucket'])
