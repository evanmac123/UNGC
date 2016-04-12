FactoryGirl.define do
  factory :mou do
    attachment { build(:uploaded_file) }
  end
end
