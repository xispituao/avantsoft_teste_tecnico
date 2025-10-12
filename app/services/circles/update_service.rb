# frozen_string_literal: true

module Circles
  class UpdateService < BaseService
    def initialize(circle:, attributes:)
      @circle = circle
      @attributes = attributes
    end

    def call
      if @circle.update(@attributes)
        @circle.frame.update_circle_positions!
      end
      @circle
    end
  end
end

