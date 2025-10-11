class Circle < ApplicationRecord
  belongs_to :frame, counter_cache: :circle_count

  validates :x_axis, presence: true, numericality: true
  validates :y_axis, presence: true, numericality: true
  validates :diameter, presence: true, numericality: { greater_than: 0 }
  validates :frame, presence: true

  validate :circle_fits_in_frame
  validate :no_circle_overlap

  after_save :update_frame_circle_positions
  after_destroy :update_frame_circle_positions

  # Retorna o raio do círculo
  def radius
    @radius ||= diameter / 2.0
  end

  private

  def circle_fits_in_frame
    return unless frame && x_axis && y_axis && diameter

    # Verificar se o círculo cabe dentro do quadro
    if x_axis - radius < frame.x_axis ||
       x_axis + radius > frame.x_axis + frame.width ||
       y_axis - radius < frame.y_axis ||
       y_axis + radius > frame.y_axis + frame.height
      errors.add(:base, I18n.t("models.circle.errors.circle_fits_in_frame"))
    end
  end

  def no_circle_overlap
    return unless frame && x_axis && y_axis && diameter

    # Verificar sobreposição usando distância euclidiana
    # Dois círculos se tocam quando: distância_entre_centros = soma_dos_raios
    # Dois círculos se sobrepõem quando: distância_entre_centros < soma_dos_raios
    # Para NÃO permitir tocar nem sobrepor, usamos <=
    overlapping_circle = frame.circles
      .where.not(id: id)
      .where(
        "POWER(x_axis - ?, 2) + POWER(y_axis - ?, 2) <= POWER((? + diameter) / 2.0, 2)",
        x_axis, y_axis, diameter
      )
      .first

    if overlapping_circle
      errors.add(:base, I18n.t("models.circle.errors.no_circle_overlap"))
    end
  end

  def update_frame_circle_positions
    frame.update_circle_positions! if frame
  end
end
