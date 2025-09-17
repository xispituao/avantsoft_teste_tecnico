class CircleSerializer < ActiveModel::Serializer
  attributes :id, :x_axis, :y_axis, :diameter, :frame_id, :created_at, :updated_at

  def x_axis
    object.x_axis.to_f
  end

  def y_axis
    object.y_axis.to_f
  end

  def diameter
    object.diameter.to_f
  end
end
