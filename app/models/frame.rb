class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_error
  accepts_nested_attributes_for :circles, allow_destroy: true, reject_if: :all_blank

  validates :x_axis, presence: true, numericality: true
  validates :y_axis, presence: true, numericality: true
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }

  validate :no_frame_overlap

  # Update circle positions after any circle changes
  def update_circle_positions!
    return reset_circle_positions! if circles.empty?

    update_columns(
      highest_circle_position: circles.minimum(:y_axis),
      lowest_circle_position: circles.maximum(:y_axis),
      leftmost_circle_position: circles.minimum(:x_axis),
      rightmost_circle_position: circles.maximum(:x_axis)
    )
  end

  private

  def no_frame_overlap
    return unless x_axis && y_axis && width && height

    # Verificar sobreposição usando lógica correta de retângulos
    # Dois retângulos se sobrepõem ou tocam quando:
    # - frame1.right >= frame2.left AND frame1.left <= frame2.right (eixo X)
    # - frame1.bottom >= frame2.top AND frame1.top <= frame2.bottom (eixo Y)
    #
    # Para NÃO permitir tocar nem sobrepor, usamos >= e <=
    overlapping_frame = Frame
      .where.not(id: id)
      .where(
        "(x_axis + width >= ? AND x_axis <= ? + ?) AND (y_axis + height >= ? AND y_axis <= ? + ?)",
        x_axis, x_axis, width, y_axis, y_axis, height
      )
      .first

    if overlapping_frame
      errors.add(:base, I18n.t("models.frame.errors.no_frame_overlap"))
    end
  end

  def reset_circle_positions!
    update_columns(
      highest_circle_position: nil,
      lowest_circle_position: nil,
      leftmost_circle_position: nil,
      rightmost_circle_position: nil
    )
  end
end
