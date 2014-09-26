class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  protect_from_forgery
  layout "card_scans"

  
  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render :show, status: :created, location: @photo }
      else
        format.html { render :new }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def camera
    @identity_id = params[:token]
    puts "identity_id"
    puts @identity_id
  end

  def canvas_capture
    Rails.logger.info params
    # File.open("#{Rails.root}/tmp/photo_123.jpg", 'wb') do |file|
    #   file.write(params[:image_data])
    # end

    # output_canvas_pic = "#{Rails.root}/tmp/" + session[:session_id].to_s + '.png'
    # data = params[:image_data]
    # image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

    # File.open(output_canvas_pic, 'wb') do |f|
    #   f.write image_data
    # end

    # source = Magick::Image.read(output_canvas_pic).first
    # source = source.resize_to_fill(465, 480).write(output_canvas_pic)

    # i = Magick::Image.read(output_canvas_pic ).first
    # i.write( "#{Rails.root}/tmp/" + session[:session_id].to_s + '.jpg' ) do
    #   self.format = 'JPEG'
    #   self.quality = 90
    # end

    # render text: "/" + session[:session_id].to_s + '.jpg'
    @photo = Photo.new
    @photo.image = File.open(camera_image(params[:image_data]))
    render text: @photo.save ? "success|#{params[:token]}|#{@photo.id}" : "Failure"
  end

  def verify
    sleep(5)
    @card_details = CardScan.where(id: params[:token1]).last
    if @card_details.present?
      @id_face = @card_details.face_image_url.to_s      
    end

    @photo_details = Photo.where(id: params[:token2]).last
    if @photo_details.present?
      @camera_photo = @photo_details.image_url.to_s      
    end
    
  end 

  def verify_status
    puts "coming to verify_status"
    puts params.inspect
    @card_id = params[:token1]
    @id_face = params[:id_face]
    @camera_photo = params[:camera_photo]
    @match_details = face_recognise_process(params[:id_face], params[:camera_photo])
    @photo = Photo.where(id: params[:token2]).first
    if @match_details["status"] && @match_details["match_score"] > 30
      stamp(@photo)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:user_id, :title, :description, :image, :remote_image_url, :image_tmp, :captured,
                  :verified, :profile_picture, :tag_name, :tag_id, :photo_id_url)
    end

    def stamp(source_photo)
      # source_img = Magick::Image.read(source_photo.image_url.to_s).first 
      source_img = Magick::Image.read("https://s3-ap-southeast-2.amazonaws.com/myverifiedid-support/documents/kp_medium.jpg").first
      stamp_path = File.join("app", "assets","images", "black-seal-stamp.png")

      if File.exists?(stamp_path) # use existing stamp image
        stamp_image = Magick::Image.read(stamp_path).first 
        stamp_img = source_img.composite!(stamp_image, Magick::SouthEastGravity, Magick::OverCompositeOp)
        # Other Gravities: SouthEastGravity, NorthGravity(centered), etc.    
        # photo_seal = "#{Rails.root}/public/uploads/#{source_photo.user_id}_photo_seal.png"
        photo_seal = "#{Rails.root}/tmp/#{source_photo.id}_photo_seal.png"
        stamp_img.write(photo_seal)
        
        # old_profile_pics = current_user.photos.where(verified: true, profile_picture: true)
        # if old_profile_pics.present? && old_profile_pics.count > 0
        #   old_profile_pics.each do |p|
        #     p.update_attributes(profile_picture: false)
        #   end
        # end

        source_photo.update_attributes(profile_picture: true, verified: true, image: File.new("#{photo_seal}"))
        sleep(5)
      end      
    end

    def camera_image(image_data)
      camera_img = "#{Rails.root}/tmp/camera_" + session[:session_id].to_s + '.png'
      data = image_data #params[:image_data]
      image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

      File.open(camera_img, 'wb') do |f|
        f.write image_data
      end

      out_image = "#{Rails.root}/tmp/camera_" + session[:session_id].to_s + '.jpg'
      img = Magick::Image.read(camera_img).first
      img.write(out_image) do
        self.format = 'JPEG'
        self.quality = 90
      end
      out_image
    end


    def face_recognise_process(id_face, camera_photo)

      biometric_client = Face.get_client(:api_key => ENV['BIOMETRIC_KEY'], :api_secret => ENV['BIOMETRIC_SECRET'])
      match_score = 0
      puts "connected to Sky Biometric client"
      puts "image url is:"
      puts camera_photo

      puts "before faces_detect"

      begin
      
        face_data = biometric_client.faces_detect(:urls => ["#{id_face}"], :attributes => "all", :detect_all_feature_points => true)

      rescue => error_details
        begin
          face_data = biometric_client.faces_detect(:urls => ["#{id_face}"], :attributes => "all", :detect_all_feature_points => true)
        rescue => error_details
          puts error_details.to_json
          #UserMailer.gdc_conn_timeout_alert.deliver
          error_details = {"status" => false, "message" => "Connection Failure! Unable to detect face tag while verifying photo. Please capture camera photo again!"}
          return error_details
        end
      end

      puts "Face details"
      puts face_data

      if face_data["status"].eql?("success") && face_data["photos"][0]["tags"].present?

        photoid_face_data = PhotoidFace.new("photo_id" => "123333", "face_details" => face_data["photos"][0])
            
        photoid_face_data.status = face_data["status"]
      
        if face_data["error_code"].present?
          photoid_face_data.error_code = face_data["error_code"]
          photoid_face_data.error_message = face_data["error_message"]
        end

        photoid_face_data.save

        puts "before tags_save"
        
        tag_id = face_data["photos"][0]["tags"][0]["tid"] if face_data["photos"][0]["tags"].present?
        tag_name = "123333@myverifiedid_photos"
        
        puts "tag id"
        puts tag_id
        puts "tag name"
        puts tag_name

        begin
          tag_data = biometric_client.tags_save(:uid => "#{tag_name}", :tids => ["#{tag_id}"])
          sleep(1)
        rescue => error_details
          begin
            tag_data = biometric_client.tags_save(:uid => "#{tag_name}", :tids => ["#{tag_id}"])
          rescue => error_details
            puts error_details.to_json
            #UserMailer.gdc_conn_timeout_alert.deliver
            error_details = {"status" => false, "message" => "Connection Failure! Unable to tag the face from detected face while verifying photo. Please capture camera photo again!"}
            return error_details
          end
        end

        puts "Tag details"
        puts tag_data

        if tag_data["status"].eql?("success")
          
          puts "before faces_train"
          new_tag_id = tag_data["saved_tags"][0]["tid"]
          puts "new tag id"
          puts new_tag_id

          begin
            face_train_data = biometric_client.faces_train(:uids => ["#{tag_name}"])
            sleep(1)
          rescue => error_details
            begin
              face_train_data = biometric_client.faces_train(:uids => ["#{tag_name}"])
            rescue => error_details
              puts error_details.to_json
              #UserMailer.gdc_conn_timeout_alert.deliver
              error_details = {"status" => false, "message" => "Connection Failure! Unable to train tag the face from detected face while verifying photo. Please capture camera photo again!"}
              return error_details
            end
          end

          puts "Face Train details"
          puts face_train_data

          if face_train_data["status"].eql?("success")
            puts "before Face recognisation"

            begin
              face_recognise_data = biometric_client.faces_recognize(:urls => ["#{camera_photo}"], :uids => ["#{tag_name}"], :attributes => "all", :detect_all_feature_points => true) 
            rescue => error_details
              begin
                face_recognise_data = biometric_client.faces_recognize(:urls => ["#{camera_photo}"], :uids => ["#{tag_name}"], :attributes => "all", :detect_all_feature_points => true) 
              rescue => error_details
                puts error_details.to_json
                #UserMailer.gdc_conn_timeout_alert.deliver
                error_details = {"status" => false, "message" => "Connection Failure! Please capture camera photo again!"}
                return error_details
              end
            end

            puts "Face recognisation details"
            puts face_recognise_data

            biometric_face_recognisation = PhotoFace.new("photo_id" => "1223333", "face_details" => face_recognise_data["photos"][0])
            
            biometric_face_recognisation.status = face_recognise_data["status"]
            
            if face_recognise_data["error_code"].present?
              biometric_face_recognisation.error_code = face_recognise_data["error_code"]
              biometric_face_recognisation.error_message = face_recognise_data["error_message"]
            end

            if face_recognise_data["photos"].present? && face_recognise_data["photos"][0]["tags"].present? && face_recognise_data["photos"][0]["tags"][0]["uids"].present?
              match_score = face_recognise_data["photos"][0]["tags"][0]["uids"][0]["confidence"]
              biometric_face_recognisation.score = match_score
            end

            if biometric_face_recognisation.save
              
              if biometric_face_recognisation.status.eql?("success")
                puts "before tag delete"
                begin
                  tag_delete_data = biometric_client.tags_remove(:tids => ["#{new_tag_id}"])
                rescue => error_details
                  begin
                    tag_delete_data = biometric_client.tags_remove(:tids => ["#{new_tag_id}"])
                  rescue => error_details
                    puts error_details.to_json
                    #UserMailer.gdc_conn_timeout_alert.deliver
                    error_details = {"status" => false, "message" => "Connection Failure! Unable to comeplete face recognization process!"}
                    return error_details
                  end
                end

                puts "tag_delete_data"
                puts tag_delete_data

                if tag_delete_data["status"].eql?("success")
                  puts "before tag train delete"
                  begin
                    face_train_delete_data = biometric_client.faces_train(:uids => ["#{tag_name}"])
                  rescue => error_details
                    begin
                      face_train_delete_data = biometric_client.faces_train(:uids => ["#{tag_name}"])
                    rescue => error_details
                      puts error_details.to_json
                      #UserMailer.gdc_conn_timeout_alert.deliver
                      error_details = {"status" => false, "message" => "Connection Failure! Unable to comeplete face recognization process!"}
                      return error_details
                    end
                  end
                  
                  puts "face_train_delete_data"
                  puts face_train_delete_data

                  if face_train_delete_data["status"].eql?("success")
                    success_details = {"status" => true, "message" => "success", "match_score" => match_score}
                    return success_details
                  else
                    error_details = {"status" => false, "message" => face_train_delete_data["error_message"] + ": error code is #{tag_data["error_code"]}"}
                    return error_details
                  end


                else
                  error_details = {"status" => false, "message" => tag_delete_data["error_message"] + ": error code is #{tag_data["error_code"]}"}
                  return error_details
                end                       

              else
                error_details = {"status" => false, "message" => biometric_face_recognisation.error_message + ": error code is #{biometric_face_recognisation.error_code}"}
                return error_details
              end

            else
              error_details = {"status" => false, "message" => "Unable to store compared camera photo due to #{biometric_face_recognisation.errors["error_message"]}. Please try again!"}
              return error_details
            end
          else
            error_details = {"status" => false, "message" => face_train_data["error_message"] + ": error code is #{face_train_data["error_code"]}"}
            return error_details
          end
        else
          error_details = {"status" => false, "message" => tag_data["error_message"] + ": error code is #{tag_data["error_code"]}"}
          return error_details
        end

      else
        if face_data["error_message"].present?
          error_details = {"status" => false, "message" => face_data["error_message"] + ": error code is #{tag_data["error_code"]}"}
          return error_details
        else
          error_details = {"status" => false, "message" => "face is not detected from Photo ID"}
          return error_details
        end
      end
    end    
end
