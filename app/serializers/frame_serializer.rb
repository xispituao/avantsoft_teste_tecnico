class FrameSerializer < ActiveModel::Serializer
  attributes :id, :x_axis, :y_axis, :width, :height, :total_circles, :created_at, :updated_at

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

  def total_circles
    object.circles_count
  end
end
