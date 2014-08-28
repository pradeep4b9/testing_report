class CardScansController < ApplicationController
  before_action :set_card_scan, only: [:show, :edit, :update, :destroy]
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
  
  def voicea
    puts params.inspect
    puts params[:voice_file]
    render :text => "ok"
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
    end
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
      next_prompt = sd_hash["prompt_hint"]
      return next_prompt
    end
end
