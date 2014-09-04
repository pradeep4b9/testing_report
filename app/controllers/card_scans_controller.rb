class CardScansController < ApplicationController
  before_action :set_card_scan, only: [:show, :edit, :update, :destroy]
  protect_from_forgery
  layout "card_scans"

  # GET /card_scans
  # GET /card_scans.json
  def index
    #@card_scans = CardScan.all
    session[:banner] = "sixt" if request.url.match("sixt")
  end

  # GET /card_scans/1
  # GET /card_scans/1.json
  def show
  end

  # GET /card_scans/new
  def new
    @card_scan = CardScan.new
  end

  # GET /card_scans/1/edit
  def edit
  end

  # POST /card_scans
  # POST /card_scans.json
  def create
    @card_scan = CardScan.new(card_scan_params)

    respond_to do |format|
      if @card_scan.save
        format.html { redirect_to @card_scan, notice: 'Card scan was successfully created.' }
        format.json { render :show, status: :created, location: @card_scan }
      else
        format.html { render :new }
        format.json { render json: @card_scan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /card_scans/1
  # PATCH/PUT /card_scans/1.json
  def update
    respond_to do |format|
      if @card_scan.update(card_scan_params)
        format.html { redirect_to @card_scan, notice: 'Card scan was successfully updated.' }
        format.json { render :show, status: :ok, location: @card_scan }
      else
        format.html { render :edit }
        format.json { render json: @card_scan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /card_scans/1
  # DELETE /card_scans/1.json
  def destroy
    @card_scan.destroy
    respond_to do |format|
      format.html { redirect_to card_scans_url, notice: 'Card scan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  def passport; end

  def driverslicense; end

  def identitycard; end
  
  def status_dailogue
    begin
      api_helper = ApiHelper.new ENV['REST_API_URL_BASE'], ENV['USERNAME'], ENV['PASSWORD'], ENV['ORGANISATION_UNIT'], ENV['CONFIGURATION_ID'], ENV['VIGO_LANGUAGE'], ENV['VIGO_AUDIO_FORMAT']
      audio_helper = AudioHelper.new
      puts "... waiting for processing to complete"
      sleep 3
      @ds_hash = api_helper.get_dialogue_summary params[:id]
      raise "Failed to get dialogue summary: #{@ds_hash["message"]}" if @ds_hash["status_code"] != "0"    
      # Print the final status of the dialogue
      puts "dailogue details"
      puts @ds_hash.inspect
      puts "Dialogue completed. Status = #{@ds_hash["dialogue_status"]}"
      @voice_details = Voice.where(dialogue_id: params[:id]).last
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  def login_dailogue
    begin
      api_helper = ApiHelper.new ENV['REST_API_URL_BASE'], ENV['USERNAME'], ENV['PASSWORD'], ENV['ORGANISATION_UNIT'], ENV['CONFIGURATION_ID'], ENV['VIGO_LANGUAGE'], ENV['VIGO_AUDIO_FORMAT']
      audio_helper = AudioHelper.new
      puts "... waiting for processing to complete to login"
      sleep 3
      @ds_hash = api_helper.get_dialogue_summary params[:id]
      raise "Failed to get dialogue summary: #{@ds_hash["message"]}" if @ds_hash["status_code"] != "0"    
      # Print the final status of the dialogue
      puts "dailogue details"
      puts @ds_hash.inspect
      puts "Dialogue completed. Status = #{@ds_hash["dialogue_status"]}"
      @voice_details = Voice.where(dialogue_id: params[:id]).last
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end


  def voice
    puts params.inspect
    puts params[:voice_file]
    begin
      api_helper = ApiHelper.new ENV['REST_API_URL_BASE'], ENV['USERNAME'], ENV['PASSWORD'], ENV['ORGANISATION_UNIT'], ENV['CONFIGURATION_ID'], ENV['VIGO_LANGUAGE'], ENV['VIGO_AUDIO_FORMAT']
      audio_helper = AudioHelper.new
      session[:claimant_id] = nil
      if session[:claimant_id].blank?
        rc_hash = api_helper.register_claimant
        raise "Failed to register claimant: #{rc_hash["message"]}" if rc_hash["status_code"] != "0"
        claimant_id = rc_hash["claimant_id"]
        puts "Registered claimant id: #{claimant_id}"
        set_claimant(claimant_id)
      end
      @next_prompt = set_dailogue(session[:claimant_id], api_helper)
      puts "session dailogue id"
      puts session[:dialogue_id]

      voice_details = Voice.new({"user_id" => "testing123voice", "claimant_id" => claimant_id, "dialogue_id" => session[:dialogue_id]} )
      voice_details.save

    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  def voicea
    
    puts "coming to voicea"
    puts params[:next_prompt]
    puts params[:dialogue_id]
    puts params[:voice_file].inspect
    @is_login = params[:is_login]

    # render :text => "ok"
    begin
      # As mentioned above, for the purposes of this sample we generate speech samples programmatically from pre-recorded audio files
      # audio_data = params[:voice_file].read
      # audio_data = open("/home/kodandapani/Desktop/2014-09-01-165833.wav", "rb") { |io| io.read }
      
      content_ext = params[:voice_file].original_filename.split(".").last
      content_type = params[:voice_file].content_type
      file_name_time = "#{Time.now.getutc.to_i}_#{params[:next_prompt]}"
      file_name = "#{file_name_time}.#{content_ext}"
      File.open("#{Rails.root}/tmp/#{file_name}", 'wb') do |file|
        file.write(params[:voice_file].read)
      end

      sleep(2)

      file_name_wav = "#{file_name_time}.raw"

      puts file_name
      puts file_name_wav

      

      system("ffmpeg -i #{Rails.root}/tmp/#{file_name} -f s16be -ar 8000 -acodec pcm_s16be #{Rails.root}/tmp/#{file_name_wav} > /dev/null 2>&1")

      sleep(5)

      audio_data = open("#{Rails.root}/tmp/#{file_name_wav}", "rb") { |io| io.read }

      api_helper = ApiHelper.new ENV['REST_API_URL_BASE'], ENV['USERNAME'], ENV['PASSWORD'], ENV['ORGANISATION_UNIT'], ENV['CONFIGURATION_ID'], ENV['VIGO_LANGUAGE'], ENV['VIGO_AUDIO_FORMAT']
      audio_helper = AudioHelper.new
      # Submit the generated audio file to the new dialogue
      puts file_name
      puts content_type
      ds_hash = api_helper.submit_phrase params[:dialogue_id], audio_data, params[:next_prompt], "audio/raw", file_name_wav
      # ds_hash = api_helper.submit_phrase "d996c0ad-2b51-43b1-a27c-e38ff34c02b4", audio_data, "3478"
      puts "submit_phrase details"
      puts ds_hash
      raise "Failed to submit phrase: #{ds_hash["message"]}" if ds_hash["status_code"] != "0"
      puts "Submitted phrase: #{params[:next_prompt]}"
      @next_prompt = ds_hash["prompt_hint"]
      # Poll until processing completes.
      if ds_hash["request_status"] == "TooManyUnprocessedPhrases"
        if @is_login.blank?
          redirect_to status_dailogue_card_scans_path(id: params[:dialogue_id])
        else
          redirect_to login_dailogue_card_scans_path(id: params[:dialogue_id])
        end
      else
        @dialogue_id = params[:dialogue_id]
      end
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  def voice_signin
    puts params.inspect
    begin
      api_helper = ApiHelper.new ENV['REST_API_URL_BASE'], ENV['USERNAME'], ENV['PASSWORD'], ENV['ORGANISATION_UNIT'], ENV['CONFIGURATION_ID'], ENV['VIGO_LANGUAGE'], ENV['VIGO_AUDIO_FORMAT']
      audio_helper = AudioHelper.new
      @next_prompt = set_dailogue(params[:claimant_id], api_helper)
      puts "session dailogue id"
      puts session[:dialogue_id]

      voice_details = Voice.new({"user_id" => "testing123voice", "claimant_id" => params[:claimant_id], "dialogue_id" => session[:dialogue_id]} )
      voice_details.save

    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end
  def canvas_capture

    Rails.logger.info  params[:image_data]
    Rails.logger.info "-----------------------"
    # [:image_data] 
    # canvas_pic = "#{File.join(root_url, 'uploads', session[:session_id].to_s + '.jpg'}"

    # begin
    #   open(filename, 'wb') do |file|
    #     file << open(canvas_pic).read
    #   end  
    # rescue Exception => e
      
    # end      
    
     output_canvas_pic = "#{Rails.root}/tmp/" + session[:session_id].to_s + '.png'

      
      data = params[:image_data]

      
      image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

      File.open(output_canvas_pic, 'wb') do |f|
        f.write image_data
      end

      source = Magick::Image.read(output_canvas_pic).first
      source = source.resize_to_fill(465, 480).write(output_canvas_pic)

      i = Magick::Image.read(output_canvas_pic ).first
      i.write( "#{Rails.root}/tmp/" + session[:session_id].to_s + '.jpg' ) do
        self.format = 'JPEG'
        self.quality = 90
      end

      render text: "/" + session[:session_id].to_s + '.jpg'


  end  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_scan
      @card_scan = CardScan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_scan_params
      params.require(:card_scan).permit(:user_id, :card_status, :name, :picture, :signature, :dob)
    end

    def set_claimant(claimant_id)
      session[:claimant_id] = claimant_id
    end

    def set_dailogue(claimant_id, api_helper)
      # Start a new dialogue for the claimant
      sd_hash = api_helper.start_dialogue claimant_id, ENV['CALL_REFERENCE']
      raise "Failed to start dialogue: #{sd_hash["message"]}" if sd_hash["status_code"] != "0"
      dialogue_id = sd_hash["dialogue_id"]
      session[:dialogue_id] = dialogue_id
      puts "Started dialogue id: #{dialogue_id}"
      # Determine which file needs to be submitted
      return sd_hash["prompt_hint"]
    end
  
end


