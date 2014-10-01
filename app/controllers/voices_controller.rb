class VoicesController < ApplicationController
  # before_action :set_voice, only: [:show, :edit, :update, :destroy]
  
  before_filter :authenticate_user!

  protect_from_forgery
  layout "card_scans"
  
  def register_status
    begin
      api_helper = set_voice_api
      puts "... waiting for processing to complete"
      sleep 3
      @ds_hash = api_helper.get_dialogue_summary params[:id]
      raise "Failed to get dialogue summary: #{@ds_hash["message"]}" if @ds_hash["status_code"] != "0"    
      puts "dailogue details"
      puts @ds_hash.inspect
      puts "Dialogue completed. Status = #{@ds_hash["dialogue_status"]}"
      if @ds_hash["dialogue_status"] == "Succeeded"
        profile = current_user.profile
        if profile.present?
          profile.voice_status = "verified"
          profile.save
        end
        flash[:notice] = "Your Voice biometric registration has been completed successfully"
        redirect_to dashboard_index_path
      else
        flash[:alert] = "Your Voice biometric registration has been failed. Please try again"
        redirect_to register_voices_path
      end
      # @voice_details = Voice.where(dialogue_id: params[:id]).last
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  def login_status
    begin
      api_helper = set_voice_api
      puts "... waiting for processing to complete to login"
      sleep 3
      @ds_hash = api_helper.get_dialogue_summary params[:id]
      raise "Failed to get dialogue summary: #{@ds_hash["message"]}" if @ds_hash["status_code"] != "0"    
      puts "dailogue details"
      puts @ds_hash.inspect
      puts "Dialogue completed. Status = #{@ds_hash["dialogue_status"]}"
      @voice_details = Voice.where(dialogue_id: params[:id]).last
      if @voice_details.present? && @ds_hash["dialogue_status"].eql?("Succeeded")
        @voice_details.login_status = true
        @voice_details.login_attempts = 0
        @voice_details.save
      end
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end


  def register
    puts params.inspect
    puts params[:voice_file]
    begin
      api_helper = set_voice_api
      puts current_user.claimant_id
     
      current_user.claimant_id = nil
      current_user.save

      if current_user.claimant_id.blank?
        rc_hash = api_helper.register_claimant
        raise "Failed to register claimant: #{rc_hash["message"]}" if rc_hash["status_code"] != "0"
        claimant_id = rc_hash["claimant_id"]
        puts "Registered claimant id: #{claimant_id}"
        set_claimant(claimant_id)
      end

      puts current_user.claimant_id
      @next_prompt = set_dailogue(current_user.claimant_id, api_helper)
      puts current_user.dialogue_id

    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  def record
    puts "coming to record_voice"
    puts params[:next_prompt]
    puts params[:dialogue_id]
    puts params[:voice_file].inspect
    @is_login = params[:is_login]
    begin
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

      api_helper = set_voice_api
      puts file_name
      puts content_type
      ds_hash = api_helper.submit_phrase params[:dialogue_id], audio_data, params[:next_prompt], "audio/raw", file_name_wav
      puts "submit_phrase details"
      puts ds_hash
      raise "Failed to submit phrase: #{ds_hash["message"]}" if ds_hash["status_code"] != "0"
      puts "Submitted phrase: #{params[:next_prompt]}"
      @next_prompt = ds_hash["prompt_hint"]
      if ds_hash["request_status"] == "TooManyUnprocessedPhrases"
        if @is_login.blank?
          redirect_to register_status_voices_path(id: params[:dialogue_id])
        else
          redirect_to login_status_voices_path(id: params[:dialogue_id])
        end
      else
        @dialogue_id = params[:dialogue_id]
      end
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  def signin
    begin
      api_helper = set_voice_api
      @next_prompt = set_dailogue(params[:claimant_id], api_helper)
      puts "session dailogue id"
      puts session[:dialogue_id]

      voice_details = Voice.where({"user_id" => "testing123voice", "claimant_id" => params[:claimant_id]} ).last
      if voice_details.present?
        voice_details.dialogue_id = session[:dialogue_id]
        voice_details.login_attempts = voice_details.login_attempts + 1
        voice_details.save
      end
    rescue Exception => e
      puts "An error occurred. #{e.message}"
    end
  end

  private
    def set_voice
      @voice = Voice.find(params[:id])
    end

    def set_voice_api
      api_helper = ApiHelper.new ENV['REST_API_URL_BASE'], ENV['USERNAME'], ENV['PASSWORD'], ENV['ORGANISATION_UNIT'], ENV['CONFIGURATION_ID'], ENV['VIGO_LANGUAGE'], ENV['VIGO_AUDIO_FORMAT'] 
      return api_helper
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:first_name, :middle_name, :last_name, :dob, :mobile_number, :profile_picture,
                                      :record_status, :voice_status)
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation,
                                   :mobile_number, :mobile_verification_code, :mobile_verification_status, :generated_at,
                                   :mobile_verification_count, :country, :claimant_id, :dialogue_id, :voice_auth_status)
    end

    def set_claimant(claimant_id)
      current_user.claimant_id =  claimant_id
      current_user.save
    end

    def set_dailogue(claimant_id, api_helper)
      sd_hash = api_helper.start_dialogue claimant_id, ENV['CALL_REFERENCE']
      raise "Failed to start dialogue: #{sd_hash["message"]}" if sd_hash["status_code"] != "0"
      dialogue_id = sd_hash["dialogue_id"]
      current_user.dialogue_id = dialogue_id
      current_user.save
      puts "Started dialogue id: #{dialogue_id}"
      return sd_hash["prompt_hint"]
    end
  
end