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
      { success: false, errors: [I18n.t('services.circle_service.errors.circle_not_found')] }
    end
  end

  def self.search_circles(params)
    # Validar parâmetros obrigatórios
    center_x = params[:center_x]&.to_f
    center_y = params[:center_y]&.to_f
    radius = params[:radius]&.to_f
    frame_id = params[:frame_id]

    if center_x.nil? || center_y.nil? || radius.nil?
      return { success: false, errors: [I18n.t('services.circle_service.errors.search_params_required')] }
    end

    if radius <= 0
      return { success: false, errors: [I18n.t('services.circle_service.errors.radius_must_be_positive')] }
    end

    # Construir query base
    query = Circle.joins(:frame)
    
    # Filtrar por frame se especificado
    if frame_id.present?
      query = query.where(frame_id: frame_id)
    end

    # Filtrar círculos completamente dentro do raio
    # Um círculo está completamente dentro do raio se:
    # - A distância do centro do círculo ao ponto central + raio do círculo <= radius
    circles = query.select do |circle|
      distance = Math.sqrt((circle.x_axis - center_x)**2 + (circle.y_axis - center_y)**2)
      circle_radius = circle.diameter / 2.0
      (distance + circle_radius) <= radius
    end

    { success: true, data: circles }
  end
end
