# frozen_string_literal: true

module Frames
  class CreateService < BaseService
    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      @frame = Frame.new(@attributes)
      if @frame.save
        @frame.update_circle_positions! if @frame.circles.any?
      end
      @frame
    end
  end
end

