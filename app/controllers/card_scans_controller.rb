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
    # Rails.logger.info params
    # Rails.logger.info("--------------------------")

    @card_scan = CardScan.new(card_scan_params)
    @card_scan.face_image = File.open(card_images(params[:card_scan][:face_image], "face"))
    @card_scan.signature_image = nil #File.open(card_images(params[:card_scan][:signature_image], "signature"))
    if @card_scan.save
      sleep(5)
      flash[:notice] = "Your Identity has been verified successfully"
      render text: "success|#{@card_scan.id}"
      # redirect_to identity_status_card_scans_path(token: @card_scan.id)
    else
      flash[:alert] = "Failed to verify the Identity. Try again or use another Identity"
      redirect_to card_scans_path
    end
    # render text: @card_scan.save ? "success" : "Failed to save."

    # render text: "OK"
    # respond_to do |format|
    #   if @card_scan.save
    #     format.html { redirect_to @card_scan, notice: 'Card scan was successfully created.' }
    #     format.json { render :show, status: :created, location: @card_scan }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @card_scan.errors, status: :unprocessable_entity }
    #   end
    # end
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

  def identity_status
    @card_scan = CardScan.where(id: params[:token]).last
  end

  def passport; end
  def driverslicense; end
  def identitycard; end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_scan
      @card_scan = CardScan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_scan_params
      params.require(:card_scan).permit(:user_id, :card_status, :first_name, :middle_name, :last_name, :address, :city, :state, 
        :zip, :street, :country, :expiration_date, :issue_date, :date_of_birth, :sex, :eyes_color, :hair_color, :height, 
        :weight, :dl_class, :restriction, :endorsements, :idcard_number, :idcard_type, :face_image, :signature_image)
    end

    def card_images(image_data, type)
      face_image = "#{Rails.root}/tmp/#{type}_" + "1" + session[:session_id].to_s + '.png'
      data = image_data #params[:image_data]
      image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

      File.open(face_image, 'wb') do |f|
        f.write image_data
      end

      if type == "face"
        source = Magick::Image.read(face_image).first
        source = source.resize_to_fill(465, 480).write(face_image)
      end

      out_image = "#{Rails.root}/tmp/#{type}_" + "1" + session[:session_id].to_s + '.jpg'
      img = Magick::Image.read(face_image).first
      img.write(out_image) do
        self.format = 'JPEG'
        self.quality = 90
      end
      out_image
    end
end


