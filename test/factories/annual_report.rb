FactoryBot.define do
  factory :annual_report do
    attachment { build(:uploaded_file) }
  end
end
