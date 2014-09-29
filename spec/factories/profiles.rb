# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile do
    first_name "MyString"
    middle_name "MyString"
    last_name "MyString"
    dob "MyString"
    mobile_number "MyString"
    profile_picture "MyString"
  end
end
