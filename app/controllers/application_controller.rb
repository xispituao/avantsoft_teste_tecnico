class ApplicationController < ActionController::API
  before_action :set_locale

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    locale = params[:locale] || extract_locale_from_accept_language_header
    I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
  end

  def extract_locale_from_accept_language_header
    return nil unless request.headers['Accept-Language']
    
    accept_language = request.headers['Accept-Language']
    return 'pt-BR' if accept_language.match?(/pt-BR/i) || accept_language.match?(/pt/i)
    return 'en' if accept_language.match?(/en/i)
    
    nil
  end
end
