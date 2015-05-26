# for the time being this model will serve as a storage for
# all the images uploaded on s3 from the CMS interface
#
# later we plan to add an image library that lets you browse them
class UploadedImage < ActiveRecord::Base
  def licensing
    if (json = read_attribute(:licensing_data))
      MultiJson.load(json, symbolize_keys: true)
    else
      {}
    end
  end

  def licensing=(hsh)
    licensing = if hsh
      MultiJson.dump(hsh)
    else
      '{}'
    end

    write_attribute :licensing_data, licensing
  end
end
