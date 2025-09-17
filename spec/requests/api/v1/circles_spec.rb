require 'swagger_helper'

RSpec.describe 'Api::V1::Circles', type: :request do
  path '/api/v1/circles' do
    get 'Lista círculos dentro de um raio' do
      tags 'Circles'
      produces 'application/json'
      parameter name: :center_x, in: :query, type: :number, required: true, description: 'Coordenada X do centro'
      parameter name: :center_y, in: :query, type: :number, required: true, description: 'Coordenada Y do centro'
      parameter name: :radius, in: :query, type: :number, required: true, description: 'Raio em centímetros'
      parameter name: :frame_id, in: :query, type: :integer, required: false, description: 'ID do quadro (opcional)'

      response '200', 'Lista de círculos retornada com sucesso' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Circle' }

        let(:frame) { create(:frame, x_axis: 7000, y_axis: 7000) }
        let(:circle) { create(:circle, frame: frame, x_axis: 7050, y_axis: 7050) }
        let(:center_x) { 7050 }
        let(:center_y) { 7050 }
        let(:radius) { 50 }

        before do
          circle
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(1)
          expect(data.first['id']).to eq(circle.id)
        end
      end

      response '422', 'Parâmetros obrigatórios ausentes' do
        schema '$ref' => '#/components/schemas/Error'

        let(:center_x) { nil }
        let(:center_y) { nil }
        let(:radius) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('center_x, center_y e radius são obrigatórios')
        end
      end

      response '422', 'Radius inválido' do
        schema '$ref' => '#/components/schemas/Error'

        let(:center_x) { 100 }
        let(:center_y) { 100 }
        let(:radius) { 0 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('radius deve ser maior que zero')
        end
      end
    end
  end

  path '/api/v1/circles/{id}' do
    parameter name: :id, in: :path, type: :integer

    put 'Atualiza um círculo' do
      tags 'Circles'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              x_axis: { type: :number },
              y_axis: { type: :number },
              diameter: { type: :number }
            }
          }
        }
      }

      response '200', 'Círculo atualizado com sucesso' do
        schema '$ref' => '#/components/schemas/Circle'

        let(:frame) { create(:frame, x_axis: 8000, y_axis: 8000) }
        let(:circle) { create(:circle, frame: frame, x_axis: 8050, y_axis: 8050) }
        let(:id) { circle.id }
        let(:circle_params) do
          {
            circle: {
              x_axis: 8060,
              y_axis: 8060
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq('8060.0')
          expect(data['y_axis']).to eq('8060.0')
        end
      end

      response '422', 'Erro de validação' do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) { create(:frame, x_axis: 9000, y_axis: 9000) }
        let(:circle) { create(:circle, frame: frame, x_axis: 9050, y_axis: 9050) }
        let(:id) { circle.id }
        let(:circle_params) do
          {
            circle: {
              x_axis: 10000,
              y_axis: 10000
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Círculo deve caber completamente dentro do quadro')
        end
      end

      response '404', 'Círculo não encontrado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }
        let(:circle_params) do
          {
            circle: {
              x_axis: 50,
              y_axis: 50
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Círculo não encontrado')
        end
      end
    end

    delete 'Remove um círculo' do
      tags 'Circles'
      produces 'application/json'

      response '204', 'Círculo removido com sucesso' do
        let(:frame) { create(:frame, x_axis: 10000, y_axis: 10000) }
        let(:circle) { create(:circle, frame: frame, x_axis: 10050, y_axis: 10050) }
        let(:id) { circle.id }

        run_test!
      end

      response '404', 'Círculo não encontrado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Círculo não encontrado')
        end
      end
    end
  end
end
