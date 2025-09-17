class FrameSerializer
  def initialize(frame)
    @frame = frame
  end

  def as_json
    {
      id: @frame.id,
      x_axis: @frame.x_axis,
      y_axis: @frame.y_axis,
      width: @frame.width,
      height: @frame.height,
      total_circles: @frame.circles_count,
      created_at: @frame.created_at,
      updated_at: @frame.updated_at
    }
  end
end
