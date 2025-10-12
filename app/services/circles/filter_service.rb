# frozen_string_literal: true

module Circles
  class FilterService < BaseService
    def initialize(params = {})
      @params = params
      @frame_id = params[:frame_id]
      @center_x = params[:center_x]
      @center_y = params[:center_y]
      @radius = params[:radius]
      @page = params[:page]
      @per_page = params[:per_page]
    end

    def call
      validate_required_params!
      
      circles = Circle.all
      circles = filter_by_frame(circles) if @frame_id.present?
      circles = filter_by_radius(circles)
      circles = paginate(circles)
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

      circles.where(
        "SQRT(POWER(x_axis - ?, 2) + POWER(y_axis - ?, 2)) + (diameter / 2.0) <= ?",
        center_x, center_y, radius
      )
    end

    def paginate(circles)
      circles.page(@page).per(@per_page)
    end
  end
end

