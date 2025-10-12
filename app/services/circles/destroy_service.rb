# frozen_string_literal: true

module Circles
  class DestroyService < BaseService
    def initialize(circle:)
      @circle = circle
    end

    def call
      frame = @circle.frame
      if @circle.destroy
        frame.update_circle_positions!
      end
    end
  end
end
