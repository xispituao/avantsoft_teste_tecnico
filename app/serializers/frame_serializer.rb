# frozen_string_literal: true

class FrameSerializer < ActiveModel::Serializer
  attributes :id,
             :x_axis,
             :y_axis,
             :width,
             :height,
             :circle_count,
             :highest_circle_position,
             :lowest_circle_position,
             :leftmost_circle_position,
             :rightmost_circle_position
end

