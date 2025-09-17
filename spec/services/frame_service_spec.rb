require 'rails_helper'

RSpec.describe FrameService, type: :service do
  describe '.create_frame' do
    context 'quando os parâmetros são válidos' do
      let(:frame_params) do
        {
          x_axis: 1000,
          y_axis: 1000,
          width: 100,
          height: 100
        }
      end

      it 'cria um frame com sucesso' do
        result = FrameService.create_frame(frame_params)

        expect(result[:success]).to be true
        expect(result[:data]).to be_a(Frame)
        expect(result[:data].x_axis).to eq(1000)
        expect(result[:data].y_axis).to eq(1000)
        expect(result[:data].width).to eq(100)
        expect(result[:data].height).to eq(100)
      end

      it 'cria um frame com círculos' do
        frame_params_with_circles = frame_params.merge(
          circles_attributes: [
            { x_axis: 1050, y_axis: 1050, diameter: 20 },
            { x_axis: 1070, y_axis: 1050, diameter: 15 }
          ]
        )

        result = FrameService.create_frame(frame_params_with_circles)

        expect(result[:success]).to be true
        expect(result[:data].circles.count).to eq(2)
      end
    end

    context 'quando os parâmetros são inválidos' do
      let(:invalid_params) do
        {
          x_axis: 50,
          y_axis: 50,
          width: 100,
          height: 100
        }
      end

      before do
        create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100, total_circles: 0)
      end

      it 'retorna erro de validação' do
        result = FrameService.create_frame(invalid_params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Quadro não pode tocar outro quadro')
      end
    end

    context 'quando há erro na criação de círculos' do
      let(:frame_params_with_invalid_circles) do
        {
          x_axis: 2000,
          y_axis: 2000,
          width: 100,
          height: 100,
          circles_attributes: [
            { x_axis: 2050, y_axis: 2050, diameter: 200 } # Muito grande para o frame
          ]
        }
      end

      it 'não cria o frame se os círculos são inválidos' do
        result = FrameService.create_frame(frame_params_with_invalid_circles)

        expect(result[:success]).to be false
        expect(Frame.count).to eq(0)
      end
    end
  end

  describe '.get_frame_details' do
    let(:frame) { create(:frame, x_axis: 3000, y_axis: 3000, width: 100, height: 100, total_circles: 0) }

    context 'quando o frame existe' do
      it 'retorna os detalhes do frame com métricas' do
        create(:circle, frame: frame, x_axis: 3050, y_axis: 3050, diameter: 20)
        create(:circle, frame: frame, x_axis: 3070, y_axis: 3070, diameter: 15)

        result = FrameService.get_frame_details(frame)

        expect(result[:success]).to be true
        expect(result[:data][:frame]).to eq(frame)
        expect(result[:data][:metrics][:total_circles]).to eq(2)
        expect(result[:data][:metrics][:highest_circle_position]).to eq(3070.0)
        expect(result[:data][:metrics][:lowest_circle_position]).to eq(3050.0)
        expect(result[:data][:metrics][:leftmost_circle_position]).to eq(3050.0)
        expect(result[:data][:metrics][:rightmost_circle_position]).to eq(3070.0)
      end

      it 'retorna métricas nulas quando não há círculos' do
        result = FrameService.get_frame_details(frame)

        expect(result[:success]).to be true
        expect(result[:data][:metrics][:total_circles]).to eq(0)
        expect(result[:data][:metrics][:highest_circle_position]).to be_nil
        expect(result[:data][:metrics][:lowest_circle_position]).to be_nil
        expect(result[:data][:metrics][:leftmost_circle_position]).to be_nil
        expect(result[:data][:metrics][:rightmost_circle_position]).to be_nil
      end
    end

    context 'quando o frame não existe' do
      it 'retorna erro' do
        result = FrameService.get_frame_details(nil)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Quadro não encontrado')
      end
    end
  end

  describe '.destroy_frame' do
    context 'quando o frame não tem círculos' do
      let(:frame) { create(:frame, x_axis: 4000, y_axis: 4000, width: 100, height: 100, total_circles: 0) }

      it 'remove o frame com sucesso' do
        result = FrameService.destroy_frame(frame)

        expect(result[:success]).to be true
        expect { frame.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'quando o frame tem círculos' do
      let(:frame) { create(:frame, x_axis: 5000, y_axis: 5000, width: 100, height: 100, total_circles: 0) }

      before do
        create(:circle, frame: frame, x_axis: 5050, y_axis: 5050, diameter: 20)
      end

      it 'não remove o frame' do
        result = FrameService.destroy_frame(frame)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Não é possível excluir quadro com círculos associados')
        expect { frame.reload }.not_to raise_error
      end
    end

    context 'quando o frame não existe' do
      it 'retorna erro' do
        result = FrameService.destroy_frame(nil)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Quadro não encontrado')
      end
    end
  end
end
