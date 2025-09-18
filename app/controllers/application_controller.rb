class ApplicationController < ActionController::Base
  include Response
  include ExceptionHandler

  allow_browser versions: :modern

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  before_action :set_locale

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
