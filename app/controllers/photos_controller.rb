class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  layout "card_scans"
  protect_from_forgery

  
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

  def canvas_capture

    Rails.logger.info params
    render text: "ok"  
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
  end  


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:user_id, :image, :image_tmp, :verified)
    end
end
