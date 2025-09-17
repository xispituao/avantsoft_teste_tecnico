class FrameSerializer
  def initialize(frame)
    @frame = frame
  end

  def as_json
    {
      id: @frame.id,
      x_axis: @frame.x_axis.to_f,
      y_axis: @frame.y_axis.to_f,
      width: @frame.width.to_f,
      height: @frame.height.to_f,
      total_circles: @frame.circles_count,
      created_at: @frame.created_at,
      updated_at: @frame.updated_at
    }
  end
end
