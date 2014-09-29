json.array!(@profiles) do |profile|
  json.extract! profile, :id, :first_name, :middle_name, :last_name, :dob, :mobile_number, :profile_picture
  json.url profile_url(profile, format: :json)
end
