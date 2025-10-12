# frozen_string_literal: true

class CirclesController < ApplicationController
  before_action :set_circle, only: %i[update destroy]
  before_action :set_frame, only: :create

  # GET /circles?center_x=X&center_y=Y&radius=R&frame_id=ID
  def index
    circles = Circles::FilterService.call(params)
    render json: circles, each_serializer: CircleSerializer
  rescue MissingParametersError => e
    render json: { error: e.message }, status: :bad_request
  end

  # POST /frames/:frame_id/circles
  def create
    @circle = Circles::CreateService.call(frame: @frame, attributes: circle_params)

    if @circle.persisted?
      render json: @circle, serializer: CircleSerializer, status: :created
    else
      render json: { errors: @circle.errors }, status: :unprocessable_entity
    end
  end

  # PUT /circles/:id
  def update
    circle = Circles::UpdateService.call(circle: @circle, attributes: circle_params)

    if circle.errors.empty?
      render json: circle, serializer: CircleSerializer
    else
      render json: { errors: circle.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /circles/:id
  def destroy
    Circles::DestroyService.call(circle: @circle)
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
