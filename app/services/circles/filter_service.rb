# frozen_string_literal: true

module Circles
  class FilterService < BaseService
    def initialize(params = {})
      @frame_id = params[:frame_id]
      @center_x = params[:center_x]&.to_f
      @center_y = params[:center_y]&.to_f
      @radius = params[:radius]&.to_f
    end

    def call
      circles = Circle.all
      circles = filter_by_frame(circles) if @frame_id.present?
      circles = filter_by_radius(circles) if radius_params_present?
      circles
    end

    private

    def filter_by_frame(circles)
      circles.where(frame_id: @frame_id)
    end

    def filter_by_radius(circles)
      circles.select do |circle|
        distance = GeometryHelper.euclidean_distance(
          @center_x, @center_y,
          circle.x_axis, circle.y_axis
        )
        # Verifica se o círculo está completamente dentro do raio
        distance + circle.radius <= @radius
      end
    end

    def radius_params_present?
      @center_x.present? && @center_y.present? && @radius.present?
    end
  end
end

