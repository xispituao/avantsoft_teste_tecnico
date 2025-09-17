class Frame < ApplicationRecord
  has_many :circles
  accepts_nested_attributes_for :circles, allow_destroy: true, reject_if: :all_blank

  validates :x_axis, presence: true, numericality: true
  validates :y_axis, presence: true, numericality: true
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :total_circles, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :no_frame_overlap

  def no_frame_overlap
    return unless x_axis && y_axis && width && height

    # Verificar sobreposição
    overlapping_frame = Frame
      .where.not(id: id)
      .where(
        "NOT (x_axis + width < ? OR x_axis > ? + ? OR y_axis + height < ? OR y_axis > ? + ?)",
        x_axis, x_axis, width, y_axis, y_axis, height
      )
      .first

    if overlapping_frame
      errors.add(:base, I18n.t('models.frame.errors.no_frame_overlap'))
    end
  end

  def rectangles_overlap_or_touch?(frame1, frame2)
    frame1_left = frame1.x_axis
    frame1_right = frame1.x_axis + frame1.width
    frame1_top = frame1.y_axis
    frame1_bottom = frame1.y_axis + frame1.height
    
    frame2_left = frame2.x_axis
    frame2_right = frame2.x_axis + frame2.width
    frame2_top = frame2.y_axis
    frame2_bottom = frame2.y_axis + frame2.height

    # Retorna true se os retângulos se sobrepõem ou se tocam
    !(frame1_right < frame2_left || frame1_left > frame2_right ||
      frame1_bottom < frame2_top || frame1_top > frame2_bottom)
  end
end
