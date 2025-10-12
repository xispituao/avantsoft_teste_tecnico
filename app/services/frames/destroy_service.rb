# frozen_string_literal: true

module Frames
  class DestroyService < BaseService
    def initialize(frame:)
      @frame = frame
    end

    def call
      if @frame.circles.any?
        { success: false, error: "Cannot delete frame with circles" }
      else
        @frame.destroy
        { success: true, error: nil }
      end
    end
  end
end

