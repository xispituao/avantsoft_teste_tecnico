# frozen_string_literal: true

module Circles
  class CreateService < BaseService
    def initialize(frame:, attributes:)
      @frame = frame
      @attributes = attributes
    end

    def call
      @circle = @frame.circles.new(@attributes)
      @circle.save
      @circle
    end
  end
end

