require 'rails_helper'

RSpec.describe CircleService, type: :service do
  describe '.create_circle' do
    let(:frame) { create(:frame, x_axis: 6000, y_axis: 6000, width: 100, height: 100, total_circles: 0) }

    context 'quando os parâmetros são válidos' do
      let(:circle_params) do
        {
          x_axis: 6050,
          y_axis: 6050,
          diameter: 20
        }
      end

      it 'cria um círculo com sucesso' do
        result = CircleService.create_circle(frame, circle_params)

        expect(result[:success]).to be true
        expect(result[:data]).to be_a(Circle)
        expect(result[:data].x_axis).to eq(6050)
        expect(result[:data].y_axis).to eq(6050)
        expect(result[:data].diameter).to eq(20)
        expect(result[:data].frame).to eq(frame)
      end
    end

    context 'quando os parâmetros são inválidos' do
      let(:invalid_params) do
        {
          x_axis: 10000,
          y_axis: 10000,
          diameter: 20
        }
      end

      it 'retorna erro de validação' do
        result = CircleService.create_circle(frame, invalid_params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Círculo deve caber completamente dentro do quadro')
      end
    end
  end

  describe '.update_circle' do
    let(:frame) { create(:frame, x_axis: 7000, y_axis: 7000, width: 100, height: 100, total_circles: 0) }
    let(:circle) { create(:circle, frame: frame, x_axis: 7050, y_axis: 7050, diameter: 20) }

    context 'quando os parâmetros são válidos' do
      let(:update_params) do
        {
          x_axis: 7060,
          y_axis: 7060
        }
      end

      it 'atualiza o círculo com sucesso' do
        result = CircleService.update_circle(circle, update_params)

        expect(result[:success]).to be true
        expect(result[:data].x_axis).to eq(7060)
        expect(result[:data].y_axis).to eq(7060)
      end
    end

    context 'quando os parâmetros são inválidos' do
      let(:invalid_params) do
        {
          x_axis: 10000,
          y_axis: 10000
        }
      end

      it 'retorna erro de validação' do
        result = CircleService.update_circle(circle, invalid_params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Círculo deve caber completamente dentro do quadro')
      end
    end
  end

  describe '.destroy_circle' do
    let(:frame) { create(:frame, x_axis: 8000, y_axis: 8000, width: 100, height: 100, total_circles: 0) }
    let(:circle) { create(:circle, frame: frame, x_axis: 8050, y_axis: 8050, diameter: 20) }

    it 'remove o círculo com sucesso' do
      result = CircleService.destroy_circle(circle)

      expect(result[:success]).to be true
      expect { circle.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.search_circles' do
    let(:frame1) { create(:frame, x_axis: 9000, y_axis: 9000, width: 100, height: 100, total_circles: 0) }
    let(:frame2) { create(:frame, x_axis: 10000, y_axis: 10000, width: 100, height: 100, total_circles: 0) }

    before do
      # Limpar outros círculos dos frames para evitar conflitos
      frame1.circles.destroy_all
      frame2.circles.destroy_all

      # Círculos no frame1
      create(:circle, frame: frame1, x_axis: 9050, y_axis: 9050, diameter: 20) # Dentro do raio
      create(:circle, frame: frame1, x_axis: 9090, y_axis: 9090, diameter: 20) # Fora do raio

      # Círculos no frame2
      create(:circle, frame: frame2, x_axis: 10050, y_axis: 10050, diameter: 20) # Dentro do raio
    end

    context 'quando os parâmetros são válidos' do
      let(:search_params) do
        {
          center_x: 9050,
          center_y: 9050,
          radius: 60
        }
      end

      it 'retorna círculos dentro do raio' do
        result = CircleService.search_circles(search_params)

        expect(result[:success]).to be true
        expect(result[:data].length).to eq(1)
        expect(result[:data].map(&:x_axis)).to include(9050.0)
      end

      it 'filtra por frame quando especificado' do
        search_params_with_frame = search_params.merge(frame_id: frame1.id)
        result = CircleService.search_circles(search_params_with_frame)

        expect(result[:success]).to be true
        expect(result[:data].length).to eq(1)
        expect(result[:data].first.x_axis).to eq(9050.0)
      end

      it 'retorna lista vazia quando não há círculos no raio' do
        search_params_no_circles = {
          center_x: 5000,
          center_y: 5000,
          radius: 10
        }
        result = CircleService.search_circles(search_params_no_circles)

        expect(result[:success]).to be true
        expect(result[:data]).to be_empty
      end
    end

    context 'quando os parâmetros são inválidos' do
      it 'retorna erro quando parâmetros obrigatórios estão ausentes' do
        result = CircleService.search_circles({})

        expect(result[:success]).to be false
        expect(result[:errors]).to include('center_x, center_y e radius são obrigatórios')
      end

      it 'retorna erro quando radius é zero' do
        search_params = {
          center_x: 100,
          center_y: 100,
          radius: 0
        }
        result = CircleService.search_circles(search_params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('radius deve ser maior que zero')
      end

      it 'retorna erro quando radius é negativo' do
        search_params = {
          center_x: 100,
          center_y: 100,
          radius: -10
        }
        result = CircleService.search_circles(search_params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('radius deve ser maior que zero')
      end
    end

    context 'testando lógica de raio' do
      let(:frame) { create(:frame, x_axis: 11000, y_axis: 11000, width: 100, height: 100, total_circles: 0) }

      before do
        # Círculo que toca exatamente o limite do raio
        create(:circle, frame: frame, x_axis: 11050, y_axis: 11050, diameter: 20)
        # Círculo que ultrapassa o limite do raio
        create(:circle, frame: frame, x_axis: 11080, y_axis: 11050, diameter: 20)
      end

      it 'inclui círculos que tocam exatamente o limite do raio' do
        search_params = {
          center_x: 11050,
          center_y: 11050,
          radius: 10
        }
        result = CircleService.search_circles(search_params)

        expect(result[:success]).to be true
        expect(result[:data].length).to eq(1)
        expect(result[:data].first.x_axis).to eq(11050.0)
      end

      it 'exclui círculos que ultrapassam o limite do raio' do
        search_params = {
          center_x: 11050,
          center_y: 11050,
          radius: 5
        }
        result = CircleService.search_circles(search_params)

        expect(result[:success]).to be true
        expect(result[:data]).to be_empty
      end
    end
  end
end
