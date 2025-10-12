# frozen_string_literal: true

module Circles
  class FilterService < BaseService
    def initialize(params = {})
      @params = params
      @frame_id = params[:frame_id]
      @center_x = params[:center_x]
      @center_y = params[:center_y]
      @radius = params[:radius]
    end

    def call
      validate_required_params!
      
      circles = Circle.all
      circles = filter_by_frame(circles) if @frame_id.present?
      circles = filter_by_radius(circles)
      circles
    end

    private

    def filter_by_frame(circles)
      circles.where(frame_id: @frame_id)
    end

    def validate_required_params!
      missing = []
      missing << 'center_x' if @center_x.blank?
      missing << 'center_y' if @center_y.blank?
      missing << 'radius' if @radius.blank?
      
      raise MissingParametersError.new(missing) if missing.any?
    end

    def filter_by_radius(circles)
      center_x = @center_x.to_f
      center_y = @center_y.to_f
      radius = @radius.to_f

      circles = circles.where(
        "x_axis BETWEEN ? AND ?",
        center_x - radius,
        center_x + radius
      ).where(
        "y_axis BETWEEN ? AND ?",
        center_y - radius,
        center_y + radius
      )

      circles.select do |circle|
        distance = GeometryHelper.euclidean_distance(
          center_x, center_y,
          circle.x_axis, circle.y_axis
        )
        distance + circle.radius <= radius
      end
    end
  end
end

