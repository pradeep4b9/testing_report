json.array!(@photos) do |photo|
  json.extract! photo, :id, :user_id, :image, :image_tmp, :verified
  json.url photo_url(photo, format: :json)
end
