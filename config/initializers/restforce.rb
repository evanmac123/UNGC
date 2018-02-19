Restforce.configure do |config|
  config.compress = true
  config.request_headers = Hash['Accept-Encoding', 'gzip,deflate']
end