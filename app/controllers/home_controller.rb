class HomeController < ApplicationController
  def index
  end

  def country_code
    country = params[:country]
    if country.blank?
      response_hash = {"code" => "00"}
    else
      code = Country.find_country_by_name(country).country_code
      response_hash = {"code" => code}
    end
    render json: response_hash
  end
end
