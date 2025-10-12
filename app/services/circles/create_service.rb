# frozen_string_literal: true

module Circles
  class CreateService < BaseService
    def initialize(frame:, attributes:)
      @frame = frame
      @attributes = attributes
    end

    def call
      @circle = @frame.circles.new(@attributes)
      if @circle.save
        @frame.update_circle_positions!
      end
      @circle
    end
  end
end

