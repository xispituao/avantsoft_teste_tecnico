class GeometryService
  class << self
    def rectangles_overlap_or_touch?(frame1, frame2)
      frame1_left = frame1.x_axis
      frame1_right = frame1.x_axis + frame1.width
      frame1_top = frame1.y_axis
      frame1_bottom = frame1.y_axis + frame1.height

      frame2_left = frame2.x_axis
      frame2_right = frame2.x_axis + frame2.width
      frame2_top = frame2.y_axis
      frame2_bottom = frame2.y_axis + frame2.height

      !(frame1_right < frame2_left || frame1_left > frame2_right ||
        frame1_bottom < frame2_top || frame1_top > frame2_bottom)
    end

    def euclidean_distance(x1, y1, x2, y2)
      Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
    end

    def circles_overlap_or_touch?(circle1, circle2)
      distance = euclidean_distance(circle1.x_axis, circle1.y_axis, circle2.x_axis, circle2.y_axis)
      sum_of_radii = circle1.radius + circle2.radius
      distance <= sum_of_radii
    end
  end
end
