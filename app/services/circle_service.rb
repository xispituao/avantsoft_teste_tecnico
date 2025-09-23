class CircleService
  def self.create_circle(frame, params)
    circle = frame.circles.build(params)

    if circle.save
      { success: true, data: circle }
    else
      { success: false, errors: circle.errors.full_messages }
    end
  end

  def self.update_circle(circle, params)
    if circle.update(params)
      { success: true, data: circle }
    else
      { success: false, errors: circle.errors.full_messages }
    end
  end

  def self.destroy_circle(circle)
    if circle.destroy
      { success: true }
    else
      { success: false, errors: [ I18n.t("services.circle_service.errors.circle_not_found") ] }
    end
  end

  def self.search_circles(params)
    # Validar parâmetros obrigatórios
    center_x = params[:center_x]
    center_y = params[:center_y]
    radius = params[:radius]
    frame_id = params[:frame_id]

    # Verificar se os parâmetros estão presentes e não são vazios
    if center_x.blank? || center_y.blank? || radius.blank?
      return { success: false, errors: [ I18n.t("services.circle_service.errors.search_params_required") ] }
    end

    center_x = center_x.to_f
    center_y = center_y.to_f
    radius = radius.to_f

    if radius <= 0
      return { success: false, errors: [ I18n.t("services.circle_service.errors.radius_must_be_positive") ] }
    end

    # Construir query base
    query = Circle.joins(:frame)

    # Filtrar por frame se especificado
    if frame_id.present?
      query = query.where(frame_id: frame_id)
    end

    # Um círculo está completamente dentro do raio se:
    # - A distância do centro do círculo ao ponto central + raio do círculo <= radius
    circles = query.where(
      "SQRT(POWER(circles.x_axis - ?, 2) + POWER(circles.y_axis - ?, 2)) + circles.diameter / 2.0 <= ?",
      center_x, center_y, radius
    )

    { success: true, data: circles }
  end
end
