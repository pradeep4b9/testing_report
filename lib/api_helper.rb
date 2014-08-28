# The following code uses functionality that is available in most standard Ruby
# distributions. Note that it can be greatly simplified using gems for processes
# such as multipart form submission and XML parsing.

require "net/http"
require "uri"
require "rexml/document"

include REXML

class ApiHelper
  
  FORM_BOUNDARY = "AaB03x"
  
  @uri_root # The base path for any API requests
  @creds    # A hash containing the username and password for this instance
  @ou       # The organisation unit ID (GUID) representing the customer for this instance
  @config   # The configuration ID (GUID) representing the settings to use for this instance
  @language # The spoken language of all prompts submitted using this instance
  @format   # The format of the recorded audio files that will be submitted
  
  # Instantiate the API helper
  def initialize uri_root, username, password, ou, config, language, format
    # Set up our instance members from the supplied parameters
    @uri_root = uri_root
    @creds = {"username" => username, "password" => password}
    @ou = ou
    @config = config
    @language = language
    @format = format
  end
  
  # Register a new "claimant" to be enrolled within VoiceVault Fusion
  def register_claimant
    params = {
      "organisation_unit" => @ou
    }
    do_post "RegisterClaimant.ashx", params, nil
  end
  
  # Begin a new enrollment or verification dialogue
  def start_dialogue claimant_id, reference
    params = {
      "configuration_id" => @config,
      "claimant_id" => claimant_id,
      "external_ref" => reference,
      "language" => @language
    }
    do_post "StartDialogue.ashx", params, nil
  end 

  # Submit audio to an existing VoiceVault Fusion dialogue
  def submit_phrase dialogue_id, phrase, prompt
    params = {
      "dialogue_id" => dialogue_id,
      "prompt" => prompt,
      "format" => @format
    }
    do_post "SubmitPhrase.ashx", params, phrase
  end

  # Retrieve the status of a dialogue
  def get_dialogue_summary dialogue_id
    params = {
      "dialogue_id" => dialogue_id
    }
    do_post "GetDialogueSummary.ashx", params, nil
  end
  
  private
  
  # An internal method that takes care of the HTTP POST to the VoiceVault Fusion REST API
  def do_post page, params, audio_file
    # Set up our HTTP request
    url_path = @uri_root + page
    uri = URI(url_path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)


    # uri = URI::join(@uri_root, page)
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # puts http.inspect
    # request = Net::HTTP::Post.new(uri)
    
    # Add our credentials to the parameters before we construct the form
    params.update @creds
    # If we have audio, we need to construct the multipart form by hand.
    # Note: gems such as "multipart" or "rest_client" can greatly simplify this process
    if (audio_file != nil)
      post_body = []

      params.each do |k, v|
        post_body << "--#{FORM_BOUNDARY}\r\n"
        post_body << "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
      end
        
      post_body << "--#{FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"utterance\"; filename=\"audio.wav\"\r\n"
      post_body << "Content-Type: audio/x-wav\r\n\r\n"
      post_body << audio_file
      post_body << "\r\n--#{FORM_BOUNDARY}--\r\n"
      
      request.content_type = "multipart/form-data, boundary=#{FORM_BOUNDARY}"
      request.body = post_body.join
    else
      # Much simpler if we're not doing a multipart submission!
      request.set_form_data(params)      
    end


    # Do the actual HTTP post
    response = http.request(request)

    # And parse the XML response into a hash
    response_xml = Document.new(response.body)
    hash = {}
    response_xml.elements.each("response_info/*") do |e|
      hash[e.name()] = e.text
    end
    
    # Return the populated hash
    hash 
  end

end