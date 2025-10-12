# frozen_string_literal: true

class MissingParametersError < StandardError
  attr_reader :missing_params

  def initialize(missing_params)
    @missing_params = missing_params
    super(message)
  end

  def message
    "Missing required parameters: #{missing_params.join(', ')}"
  end
end

