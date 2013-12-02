require "open-uri"

desc 'Updates all the resource images'
task :update_resource_images, [:path] => :environment do |t, args|
   resources = Resource.where("image_url is not null and image_url!='' and image_file_name is null")
   resources.each do |r|
    uri = URI.parse(r.image_url)
    if uri.scheme.nil?
      uri = URI.parse("http://www.unglobalcompact.org/" + r.image_url)
    end
    r.image = uri
    r.save
   end


end
