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
end


