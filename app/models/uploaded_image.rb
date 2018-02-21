# == Schema Information
#
# Table name: uploaded_images
#
#  id             :integer          not null, primary key
#  url            :string(255)      not null
#  filename       :string(255)
#  mime           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  licensing_data :text
#  has_licensing  :boolean          default(FALSE)
#

# for the time being this model will serve as a storage for
# all the images uploaded on s3 from the CMS interface
#
# later we plan to add an image library that lets you browse them
class UploadedImage < ActiveRecord::Base
  validates :url, length: { maximum: 255, too_long: "has a %{count} character limit" }
  
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
