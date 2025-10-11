# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Circles API', type: :request do
  before { host! 'localhost:3000' }

  path '/frames/{frame_id}/circles' do
    parameter name: :frame_id, in: :path, type: :integer

    post 'Adiciona circle ao frame' do
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
            },
            required: %w[x_axis y_axis diameter]
          }
        }
      }

      response '201', 'circle criado' do
        let(:frame_id) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100).id }
        let(:circle) { { circle: { x_axis: 50, y_axis: 50, diameter: 10 } } }

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['frame_id']).to eq(frame_id)
        end
      end

      response '422', 'circle não cabe no frame' do
        let(:frame_id) { create(:frame, x_axis: 0, y_axis: 0, width: 10, height: 10).id }
        let(:circle) { { circle: { x_axis: 50, y_axis: 50, diameter: 20 } } }

        run_test!
      end

      response '404', 'frame não encontrado' do
        let(:frame_id) { 999999 }
        let(:circle) { { circle: { x_axis: 5, y_axis: 5, diameter: 2 } } }

        run_test!
      end
    end
  end

  path '/circles' do
    get 'Lista circles com filtro por raio' do
      tags 'Circles'
      produces 'application/json'
      description 'Lista circles dentro de raio especificado, opcionalmente filtrados por frame'

      parameter name: :center_x, in: :query, type: :number, required: false
      parameter name: :center_y, in: :query, type: :number, required: false
      parameter name: :radius, in: :query, type: :number, required: false
      parameter name: :frame_id, in: :query, type: :integer, required: false

      response '200', 'lista de circles' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              frame_id: { type: :integer },
              x_axis: { type: :number },
              y_axis: { type: :number },
              diameter: { type: :number }
            }
          }

        let(:center_x) { nil }
        let(:center_y) { nil }
        let(:radius) { nil }
        let(:frame_id) { nil }

        run_test!
      end

      response '200', 'circles filtrados por raio' do
        let(:test_frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }
        let!(:circle_inside) { create(:circle, frame: test_frame, x_axis: 5, y_axis: 5, diameter: 2) }
        let!(:circle_outside) { create(:circle, frame: test_frame, x_axis: 50, y_axis: 50, diameter: 2) }
        let(:center_x) { 0 }
        let(:center_y) { 0 }
        let(:radius) { 10 }
        let(:frame_id) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data.first['id']).to eq(circle_inside.id)
        end
      end
    end
  end

  path '/circles/{id}' do
    parameter name: :id, in: :path, type: :integer

    put 'Atualiza posição do circle' do
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
              y_axis: { type: :number }
            }
          }
        }
      }

      response '200', 'circle atualizado' do
        let(:id) { create(:circle).id }
        let(:circle) { { circle: { x_axis: 30 } } }

        run_test!
      end

      response '422', 'posição inválida' do
        let(:test_frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }
        let(:test_circle) { create(:circle, frame: test_frame, x_axis: 50, y_axis: 50, diameter: 10) }
        let(:id) { test_circle.id }
        let(:circle) { { circle: { x_axis: 1000 } } }

        run_test!
      end

      response '404', 'circle não encontrado' do
        let(:id) { 999999 }
        let(:circle) { { circle: { x_axis: 5 } } }

        run_test!
      end
    end

    delete 'Remove circle' do
      tags 'Circles'

      response '204', 'circle removido' do
        let(:id) { create(:circle).id }

        run_test!
      end

      response '404', 'circle não encontrado' do
        let(:id) { 999999 }

        run_test!
      end
    end
  end
end
