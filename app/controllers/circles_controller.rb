# frozen_string_literal: true

class CirclesController < ApplicationController
  before_action :set_circle, only: %i[update destroy]
  before_action :set_frame, only: :create

  # GET /circles?center_x=X&center_y=Y&radius=R&frame_id=ID
  def index
    circles = Circle.all
    circles = circles.where(frame_id: params[:frame_id]) if params[:frame_id].present?

    # Filtra circles dentro do raio especificado
    if params[:center_x].present? && params[:center_y].present? && params[:radius].present?
      center_x = params[:center_x].to_f
      center_y = params[:center_y].to_f
      radius = params[:radius].to_f

      circles = circles.select do |circle|
        distance = GeometryService.euclidean_distance(
          center_x, center_y,
          circle.x_axis, circle.y_axis
        )
        distance <= radius
      end
    end

    render json: circles
  end

  # POST /frames/:frame_id/circles
  def create
    @circle = @frame.circles.new(circle_params)

    if @circle.save
      render json: @circle, status: :created
    else
      render json: { errors: @circle.errors }, status: :unprocessable_entity
    end
  end

  # PUT /circles/:id
  def update
    if @circle.update(circle_params)
      render json: @circle
    else
      render json: { errors: @circle.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /circles/:id
  def destroy
    @circle.destroy
    head :no_content
  end

  private

  def set_frame
    @frame = Frame.find(params[:frame_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def set_circle
    @circle = Circle.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def circle_params
    params.require(:circle).permit(:x_axis, :y_axis, :diameter)
  end
end
