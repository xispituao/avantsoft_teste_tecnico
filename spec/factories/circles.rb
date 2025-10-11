FactoryBot.define do
  factory :circle do
    association :frame

    x_axis { frame.x_axis + (frame.width / 2) }
    y_axis { frame.y_axis + (frame.height / 2) }
    diameter { 5.0 }

    trait :small do
      diameter { 1.0 }
    end

    trait :medium do
      diameter { 5.0 }
    end

    trait :large do
      diameter { 20.0 }
    end

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

    trait :outside_frame do
      x_axis { frame.x_axis - 10.0 }
      y_axis { frame.y_axis - 10.0 }
    end
  end
end
