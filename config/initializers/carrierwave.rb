CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],                        # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
    :region                 => 'ap-southeast-2',
    :endpoint               => 'https://s3-ap-southeast-2.amazonaws.com'
  	}
  config.fog_directory  = 'mvi-dev-secured'                     # required
  # config.fog_public     = false                                 # optional, defaults to true
  # config.fog_authenticated_url_expiration = 120
  config.fog_attributes = {'x-amz-server-side-encryption' => 'AES256','Cache-Control'=>'max-age=315576000'}
end

