# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.where(email: "admin@myverifiedid.com").first
if user.blank?
  user = User.create!({first_name: "Shyam K", last_name: "J",  email: "admin@myverifiedid.com", password: "admin123",
    mobile_number: "918688468400", mobile_verification_status: true, country: "India"})
  user.confirm!
end


Profile.create!({first_name: user.first_name, last_name: user.last_name, mobile_number: user.mobile_number,
  gender: "Male", country: "India", mobile_ctry_code: "91", record_status: nil, user_id: user.id }) if user.profile.blank?

