# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    user_id "MyString"
    image "MyString"
    image_tmp "MyString"
    verified "MyString"
  end
end
