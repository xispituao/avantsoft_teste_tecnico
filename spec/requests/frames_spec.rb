# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Frames API', type: :request do
  include SwaggerSchemas
  
  before { host! 'localhost:3000' }

  path '/frames' do
    post 'Cria um novo frame' do
      tags 'Frames'
      consumes 'application/json'
      produces 'application/json'
      description 'Cria frame e opcionalmente circles aninhados'

      parameter name: :frame, in: :body, schema: SwaggerSchemas::FRAME_INPUT

      response '201', 'frame criado' do
        schema SwaggerSchemas::FRAME_RESPONSE
        let(:frame) { { frame: { x_axis: 0, y_axis: 0, width: 100, height: 100 } } }

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['id']).to be_present
        end
      end

      response '201', 'frame criado com circles' do
        schema SwaggerSchemas::FRAME_RESPONSE
        let(:frame) do
          {
            frame: {
              x_axis: 0,
              y_axis: 0,
              width: 100,
              height: 100,
              circles_attributes: [
                { x_axis: 25, y_axis: 25, diameter: 10 },
                { x_axis: 75, y_axis: 75, diameter: 10 }
              ]
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['circle_count']).to eq(2)
        end
      end

      response '422', 'parâmetros inválidos' do
        schema SwaggerSchemas::VALIDATION_ERRORS
        let(:frame) { { frame: { width: -1 } } }

        run_test!
      end

      response '422', 'frame sobrepõe outro' do
        schema SwaggerSchemas::VALIDATION_ERRORS
        let!(:existing_frame) { create(:frame, x_axis: 0, y_axis: 0, width: 10, height: 10) }
        let(:frame) { { frame: { x_axis: 5, y_axis: 5, width: 10, height: 10 } } }

        run_test!
      end
    end
  end

  path '/frames/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Retorna detalhes do frame com métricas' do
      tags 'Frames'
      produces 'application/json'
      description 'Retorna frame com total de circles e posições extremas'

      response '200', 'frame encontrado' do
        schema SwaggerSchemas::FRAME_RESPONSE

        let(:id) { create(:frame).id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data).to have_key('circle_count')
          expect(data).to have_key('highest_circle_position')
        end
      end

      response '404', 'frame não encontrado' do
        schema SwaggerSchemas::ERROR
        let(:id) { 999999 }

        run_test!
      end
    end

    delete 'Remove frame' do
      tags 'Frames'
      description 'Remove frame apenas se não houver circles associados'

      response '204', 'frame removido' do
        let(:id) { create(:frame).id }

        run_test!
      end

      response '422', 'frame possui circles' do
        schema SwaggerSchemas::ERROR
        let(:frame_with_circles) { create(:frame) }
        let!(:circle) { create(:circle, frame: frame_with_circles) }
        let(:id) { frame_with_circles.id }

        run_test!
      end
    end
  end
end
