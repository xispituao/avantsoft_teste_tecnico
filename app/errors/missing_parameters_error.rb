# frozen_string_literal: true

class MissingParametersError < StandardError
  attr_reader :missing_params

  def initialize(missing_params)
    @missing_params = missing_params
    super(message)
  end

  def message
    I18n.t("errors.messages.missing_parameters", params: missing_params.join(", "))
  end
end
