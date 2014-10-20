class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to dashboard_index_path
    end
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

  def mvi_widget
    @email = params[:email]
  end

end
