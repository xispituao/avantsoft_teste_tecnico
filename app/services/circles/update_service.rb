# frozen_string_literal: true

module Circles
  class UpdateService < BaseService
    def initialize(circle:, attributes:)
      @circle = circle
      @attributes = attributes
    end

    def call
      @circle.update(@attributes)
      @circle
    end
  end
end

