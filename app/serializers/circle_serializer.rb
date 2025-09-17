class CircleSerializer
  def initialize(circle)
    @circle = circle
  end

  def as_json
    {
      id: @circle.id,
      x_axis: @circle.x_axis.to_f,
      y_axis: @circle.y_axis.to_f,
      diameter: @circle.diameter.to_f,
      frame_id: @circle.frame_id,
      created_at: @circle.created_at,
      updated_at: @circle.updated_at
    }
  end
end
