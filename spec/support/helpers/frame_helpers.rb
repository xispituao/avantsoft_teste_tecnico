module FrameHelpers
  # Helper to create a frame at a specific position with dimensions
  def frame_at(x:, y:, width: 50, height: 50)
    build(:frame, x_axis: x, y_axis: y, width: width, height: height)
  end

  # Helper to create a frame that touches another on the right
  def frame_touching_right(reference_frame, width: 50, height: 50)
    build(:frame, 
      x_axis: reference_frame.x_axis + reference_frame.width,
      y_axis: reference_frame.y_axis,
      width: width,
      height: height
    )
  end

  # Helper to create a frame that touches another on the bottom
  def frame_touching_bottom(reference_frame, width: 50, height: 50)
    build(:frame,
      x_axis: reference_frame.x_axis,
      y_axis: reference_frame.y_axis + reference_frame.height,
      width: width,
      height: height
    )
  end

  # Helper to create a frame separated from another
  def frame_separated_from(reference_frame, gap: 10, direction: :right, width: 50, height: 50)
    case direction
    when :right
      x = reference_frame.x_axis + reference_frame.width + gap
      y = reference_frame.y_axis
    when :bottom
      x = reference_frame.x_axis
      y = reference_frame.y_axis + reference_frame.height + gap
    when :diagonal
      x = reference_frame.x_axis + reference_frame.width + gap
      y = reference_frame.y_axis + reference_frame.height + gap
    end

    build(:frame, x_axis: x, y_axis: y, width: width, height: height)
  end
end

RSpec.configure do |config|
  config.include FrameHelpers, type: :model
end

