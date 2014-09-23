require "rest_client"
require 'json'

# UrlShorther 
# Use it UrlShortner.shortner(link)
# It will return and sorted url "http://goo.gl/J4p9jd"

class UrlShortner
	def self.shortner(link)
		begin
			response = RestClient.post('https://www.googleapis.com/urlshortener/v1/url', {"longUrl" => link }.to_json, headers = {'Content-Type' => 'application/json'})
			response = JSON.parse response
			shortned_url = response["id"]
		rescue Exception => e
			e
		end
	end
end
