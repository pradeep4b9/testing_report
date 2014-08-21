json.array!(@card_scans) do |card_scan|
  json.extract! card_scan, :id, :user_id, :card_status, :name, :picture, :signature, :dob
  json.url card_scan_url(card_scan, format: :json)
end
