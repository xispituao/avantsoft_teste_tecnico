require 'swagger_helper'

RSpec.describe 'Api::V1::Circles', type: :request do
  path '/api/v1/circles' do
    get I18n.t('swagger.operations.circles.index') do
      tags I18n.t('swagger.tags.circles')
      produces 'application/json'
      parameter name: :center_x, in: :query, type: :number, required: true, description: I18n.t('swagger.parameters.center_x')
      parameter name: :center_y, in: :query, type: :number, required: true, description: I18n.t('swagger.parameters.center_y')
      parameter name: :radius, in: :query, type: :number, required: true, description: I18n.t('swagger.parameters.radius')
      parameter name: :frame_id, in: :query, type: :integer, required: false, description: I18n.t('swagger.parameters.frame_id')

      response '200', I18n.t('swagger.responses.success.circles_listed') do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Circle' }

        let(:frame) { create(:frame, x_axis: 7000, y_axis: 7000, width: 100, height: 100, total_circles: 0) }
        let(:circle) { create(:circle, frame: frame, x_axis: 7050, y_axis: 7050, diameter: 20) }
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

      response '422', I18n.t('swagger.test_responses.success.parameters_missing') do
        schema '$ref' => '#/components/schemas/Error'

        let(:center_x) { nil }
        let(:center_y) { nil }
        let(:radius) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('services.circle_service.errors.search_params_required'))
        end
      end

      response '422', I18n.t('swagger.test_responses.success.radius_invalid') do
        schema '$ref' => '#/components/schemas/Error'

        let(:center_x) { 100 }
        let(:center_y) { 100 }
        let(:radius) { 0 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('services.circle_service.errors.radius_must_be_positive'))
        end
      end
    end
  end

  path '/api/v1/circles/{id}' do
    parameter name: :id, in: :path, type: :integer

    put I18n.t('swagger.test_operations.update_circle') do
      tags I18n.t('swagger.test_tags.circles')
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

      response '200', I18n.t('swagger.test_responses.success.circle_updated') do
        schema '$ref' => '#/components/schemas/Circle'

        let(:frame) { create(:frame, x_axis: 8000, y_axis: 8000, width: 100, height: 100, total_circles: 0) }
        let(:circle) { create(:circle, frame: frame, x_axis: 8050, y_axis: 8050, diameter: 20) }
        let(:id) { circle.id }
        let(:circle_params) do
          {
            circle: {
              x_axis: 8050,
              y_axis: 8050
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq(8050.0)
          expect(data['y_axis']).to eq(8050.0)
        end
      end


      response '404', I18n.t('swagger.test_responses.success.circle_not_found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }
        let(:circle) { nil }
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
          expect(data['errors']).to include(I18n.t('controllers.circles.errors.circle_not_found'))
        end
      end
    end

    delete I18n.t('swagger.test_operations.remove_circle') do
      tags I18n.t('swagger.test_tags.circles')
      produces 'application/json'

      response '204', I18n.t('swagger.test_responses.success.circle_removed') do
        let(:frame) { create(:frame, x_axis: 10000, y_axis: 10000, width: 100, height: 100, total_circles: 0) }
        let(:circle) { create(:circle, frame: frame, x_axis: 10050, y_axis: 10050, diameter: 20) }
        let(:id) { circle.id }

        run_test!
      end

      response '404', I18n.t('swagger.test_responses.success.circle_not_found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('controllers.circles.errors.circle_not_found'))
        end
      end
    end
  end

  # Testes simples e diretos (sem RSwag)
  describe 'PUT /api/v1/circles/:id - Testes Simples' do
    context 'quando tentamos atualizar um círculo para posição inválida' do
      it 'retorna erro 422' do
        # Criar frame e círculo
        frame = Frame.create!(
          x_axis: 9000, 
          y_axis: 9000, 
          width: 100, 
          height: 100, 
          total_circles: 0
        )
        
        circle = Circle.create!(
          frame: frame, 
          x_axis: 9050, 
          y_axis: 9050, 
          diameter: 20
        )
        
        # Tentar atualizar para posição que não cabe no frame
        put "/api/v1/circles/#{circle.id}", params: {
          circle: {
            x_axis: 9200,
            y_axis: 9050,
            diameter: 20
          }
        }
        
        # Verificar resposta
        expect(response).to have_http_status(:unprocessable_entity)
        
        data = JSON.parse(response.body)
        expect(data['errors']).to include('Círculo deve caber completamente dentro do quadro')
      end
    end
    
    context 'quando tentamos atualizar um círculo para posição válida' do
      it 'retorna sucesso 200' do
        # Criar frame e círculo
        frame = Frame.create!(
          x_axis: 9000, 
          y_axis: 9000, 
          width: 100, 
          height: 100, 
          total_circles: 0
        )
        
        circle = Circle.create!(
          frame: frame, 
          x_axis: 9050, 
          y_axis: 9050, 
          diameter: 20
        )
        
        # Atualizar para posição válida
        put "/api/v1/circles/#{circle.id}", params: {
          circle: {
            x_axis: 9060,
            y_axis: 9050,
            diameter: 20
          }
        }
        
        # Verificar resposta
        expect(response).to have_http_status(:ok)
        
        data = JSON.parse(response.body)
        expect(data['x_axis']).to eq(9060.0)
        expect(data['y_axis']).to eq(9050.0)
      end
    end
  end
end
