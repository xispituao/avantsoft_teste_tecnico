# frozen_string_literal: true

class FramesController < ApplicationController
  before_action :set_frame, only: %i[show destroy]

  # POST /frames
  def create
    @frame = Frame.new(frame_params)

    if @frame.save
      render json: @frame, serializer: FrameSerializer, status: :created
    else
      render json: { errors: @frame.errors }, status: :unprocessable_entity
    end
  end

  # GET /frames/:i
  def show
    render json: @frame, serializer: FrameSerializer
  end

  # DELETE /frames/:id
  def destroy
    if @frame.circles.any?
      render json: { error: "Cannot delete frame with circles" }, status: :unprocessable_entity
    else
      @frame.destroy
      head :no_content
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def frame_params
    params.require(:frame).permit(
      :x_axis, :y_axis, :width, :height,
      circles_attributes: %i[x_axis y_axis diameter]
    )
  end
end
