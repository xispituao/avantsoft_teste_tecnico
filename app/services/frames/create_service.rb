# frozen_string_literal: true

module Frames
  class CreateService < BaseService
    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      @frame = Frame.new(@attributes)
      @frame.save
      @frame
    end
  end
end

