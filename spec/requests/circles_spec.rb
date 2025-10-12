# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Circles API', type: :request do
  include SwaggerSchemas

  before { host! 'localhost:3000' }

  path '/frames/{frame_id}/circles' do
    parameter name: :frame_id, in: :path, type: :integer

    post 'Adiciona circle ao frame' do
      tags 'Circles'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :circle, in: :body, schema: SwaggerSchemas::CIRCLE_INPUT

      response '201', 'circle criado' do
        schema SwaggerSchemas::CIRCLE_RESPONSE
        let(:frame_id) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100).id }
        let(:circle) { { circle: { x_axis: 50, y_axis: 50, diameter: 10 } } }

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['frame_id']).to eq(frame_id)
        end
      end

      response '422', 'circle não cabe no frame' do
        schema SwaggerSchemas::VALIDATION_ERRORS
        let(:frame_id) { create(:frame, x_axis: 0, y_axis: 0, width: 10, height: 10).id }
        let(:circle) { { circle: { x_axis: 50, y_axis: 50, diameter: 20 } } }

        run_test!
      end

      response '404', 'frame não encontrado' do
        schema SwaggerSchemas::ERROR
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

      parameter name: :center_x, in: :query, type: :number, required: true, description: 'Coordenada X do centro'
      parameter name: :center_y, in: :query, type: :number, required: true, description: 'Coordenada Y do centro'
      parameter name: :radius, in: :query, type: :number, required: true, description: 'Raio de busca'
      parameter name: :frame_id, in: :query, type: :integer, required: false, description: 'ID do frame (opcional)'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Número da página (padrão: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Itens por página (padrão: 25)'

      response '400', 'parâmetros obrigatórios faltando' do
        schema SwaggerSchemas::ERROR

        context 'sem center_x' do
          let(:center_x) { nil }
          let(:center_y) { 0 }
          let(:radius) { 10 }
          let(:frame_id) { nil }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['error']).to include('center_x')
          end
        end

        context 'sem center_y' do
          let(:center_x) { 0 }
          let(:center_y) { nil }
          let(:radius) { 10 }
          let(:frame_id) { nil }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['error']).to include('center_y')
          end
        end

        context 'sem radius' do
          let(:center_x) { 0 }
          let(:center_y) { 0 }
          let(:radius) { nil }
          let(:frame_id) { nil }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['error']).to include('radius')
          end
        end

        context 'sem nenhum parâmetro' do
          let(:center_x) { nil }
          let(:center_y) { nil }
          let(:radius) { nil }
          let(:frame_id) { nil }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['error']).to include('center_x')
            expect(data['error']).to include('center_y')
            expect(data['error']).to include('radius')
          end
        end
      end

      response '200', 'circles filtrados por raio' do
        schema SwaggerSchemas::CIRCLES_ARRAY
        header 'X-Total-Count', type: :integer, description: 'Total de registros'
        header 'X-Total-Pages', type: :integer, description: 'Total de páginas'
        header 'X-Current-Page', type: :integer, description: 'Página atual'
        header 'X-Per-Page', type: :integer, description: 'Itens por página'

        let(:test_frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }
        let!(:circle_inside) { create(:circle, frame: test_frame, x_axis: 5, y_axis: 5, diameter: 2) }
        let!(:circle_outside) { create(:circle, frame: test_frame, x_axis: 50, y_axis: 50, diameter: 2) }
        let(:center_x) { 0 }
        let(:center_y) { 0 }
        let(:radius) { 10 }
        let(:frame_id) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data.first['id']).to eq(circle_inside.id)
          expect(response.headers['X-Total-Count']).to be_present
          expect(response.headers['X-Current-Page']).to eq('1')
        end
      end

      response '200', 'circles paginados' do
        schema SwaggerSchemas::CIRCLES_ARRAY
        header 'X-Total-Count', type: :integer
        header 'X-Total-Pages', type: :integer
        header 'X-Current-Page', type: :integer
        header 'X-Per-Page', type: :integer

        let(:test_frame) { create(:frame, x_axis: 0, y_axis: 0, width: 200, height: 200) }
        let!(:circles_list) do
          30.times.map do |i|
            create(:circle, frame: test_frame, x_axis: 10 + (i * 5), y_axis: 10, diameter: 2)
          end
        end
        let(:center_x) { 0 }
        let(:center_y) { 0 }
        let(:radius) { 200 }
        let(:frame_id) { nil }
        let(:page) { 2 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(10)
          expect(response.headers['X-Total-Count'].to_i).to be >= 30
          expect(response.headers['X-Current-Page']).to eq('2')
          expect(response.headers['X-Per-Page']).to eq('10')
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

      parameter name: :circle, in: :body, schema: SwaggerSchemas::CIRCLE_INPUT

      response '200', 'circle atualizado' do
        schema SwaggerSchemas::CIRCLE_RESPONSE
        let(:id) { create(:circle).id }
        let(:circle) { { circle: { x_axis: 30 } } }

        run_test!
      end

      response '422', 'posição inválida' do
        schema SwaggerSchemas::VALIDATION_ERRORS
        let(:test_frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }
        let(:test_circle) { create(:circle, frame: test_frame, x_axis: 50, y_axis: 50, diameter: 10) }
        let(:id) { test_circle.id }
        let(:circle) { { circle: { x_axis: 1000 } } }

        run_test!
      end

      response '404', 'circle não encontrado' do
        schema SwaggerSchemas::ERROR
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
        schema SwaggerSchemas::ERROR
        let(:id) { 999999 }

        run_test!
      end
    end
  end
end
