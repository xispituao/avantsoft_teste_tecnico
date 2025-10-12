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

  def x_axis
    object.x_axis.to_f
  end

  def y_axis
    object.y_axis.to_f
  end

  def width
    object.width.to_f
  end

  def height
    object.height.to_f
  end

  def highest_circle_position
    object.highest_circle_position&.to_f
  end

  def lowest_circle_position
    object.lowest_circle_position&.to_f
  end

  def leftmost_circle_position
    object.leftmost_circle_position&.to_f
  end

  def rightmost_circle_position
    object.rightmost_circle_position&.to_f
  end
end

