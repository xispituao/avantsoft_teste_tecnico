# frozen_string_literal: true

class FramesController < ApplicationController
  before_action :set_frame, only: %i[show destroy]

  # POST /frames
  def create
    @frame = Frames::CreateService.call(attributes: frame_params)

    if @frame.persisted?
      render json: @frame, serializer: FrameSerializer, status: :created
    else
      render json: { errors: @frame.errors }, status: :unprocessable_content
    end
  end

  # GET /frames/:i
  def show
    render json: @frame, serializer: FrameSerializer
  end

  # DELETE /frames/:id
  def destroy
    result = Frames::DestroyService.call(frame: @frame)

    if result[:success]
      head :no_content
    else
      render json: { error: result[:error] }, status: :unprocessable_content
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.models.frame.not_found") }, status: :not_found
  end

  def frame_params
    params.require(:frame).permit(
      :x_axis, :y_axis, :width, :height,
      circles_attributes: %i[x_axis y_axis diameter]
    )
  end
end
