class ApplicationController < ActionController::API
  include PaginationHelper
  
  before_action :set_locale

  private

  def set_locale
    if request.headers["Accept-Language"].present?
      locale = request.headers["Accept-Language"].split(",").first&.strip&.split("-")&.first&.downcase

      # Mapear 'en' para :en e 'pt' para :'pt-BR'
      case locale
      when "en"
        I18n.locale = :en
      when "pt"
        I18n.locale = :'pt-BR'
      else
        I18n.locale = I18n.default_locale
      end
    else
      I18n.locale = I18n.default_locale
    end
  end
end
