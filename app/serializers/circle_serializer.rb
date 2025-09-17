class CircleSerializer
  def initialize(circle)
    @circle = circle
  end

  def as_json
    {
      id: @circle.id,
      x_axis: @circle.x_axis,
      y_axis: @circle.y_axis,
      diameter: @circle.diameter,
      frame_id: @circle.frame_id,
      created_at: @circle.created_at,
      updated_at: @circle.updated_at
    }
  end
end
