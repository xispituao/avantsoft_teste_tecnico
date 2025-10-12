# frozen_string_literal: true

module Circles
  class DestroyService < BaseService
    def initialize(circle:)
      @circle = circle
    end

    def call
      @circle.destroy
    end
  end
end

