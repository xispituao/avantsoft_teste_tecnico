FactoryBot.define do
  factory :circle do
    association :frame
    
    # Default: circle centered in frame with small diameter
    # For multiple circles, pass explicit x_axis, y_axis values in tests
    x_axis { frame.x_axis + (frame.width / 2) }
    y_axis { frame.y_axis + (frame.height / 2) }
    diameter { 5.0 }

    # Small circle that fits easily in most frames
    trait :small do
      diameter { 1.0 }
    end

    # Medium circle
    trait :medium do
      diameter { 5.0 }
    end

    # Large circle (may not fit in small frames)
    trait :large do
      diameter { 20.0 }
    end

    # Circle positioned at specific corner/edge
    trait :top_left do
      x_axis { frame.x_axis + (diameter / 2) }
      y_axis { frame.y_axis + (diameter / 2) }
    end

    trait :top_right do
      x_axis { frame.x_axis + frame.width - (diameter / 2) }
      y_axis { frame.y_axis + (diameter / 2) }
    end

    trait :bottom_left do
      x_axis { frame.x_axis + (diameter / 2) }
      y_axis { frame.y_axis + frame.height - (diameter / 2) }
    end

    trait :bottom_right do
      x_axis { frame.x_axis + frame.width - (diameter / 2) }
      y_axis { frame.y_axis + frame.height - (diameter / 2) }
    end

    # Circle that doesn't fit in frame (for testing validation)
    trait :outside_frame do
      x_axis { frame.x_axis - 10.0 }
      y_axis { frame.y_axis - 10.0 }
    end
  end
end

