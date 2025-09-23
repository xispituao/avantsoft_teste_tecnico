require 'swagger_helper'

RSpec.describe 'Api::V1::Circles', type: :request do
  path '/api/v1/circles' do
    get 'Lista círculos' do
      tags 'Circles'
      produces 'application/json'
      parameter name: :center_x, in: :query, type: :number, required: true, description: 'Coordenada X do centro'
      parameter name: :center_y, in: :query, type: :number, required: true, description: 'Coordenada Y do centro'
      parameter name: :radius, in: :query, type: :number, required: true, description: 'Raio de busca'
      parameter name: :frame_id, in: :query, type: :integer, required: false, description: 'ID do quadro (opcional)'

      response '200', 'Lista de círculos retornada com sucesso' do
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

      response '422', 'Parâmetros obrigatórios ausentes' do
        schema '$ref' => '#/components/schemas/Error'

        let(:center_x) { nil }
        let(:center_y) { nil }
        let(:radius) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('services.circle_service.errors.search_params_required'))
        end
      end

      response '422', 'Raio inválido' do
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

    put 'Atualiza círculo' do
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


      response '404', 'Círculo não encontrado' do
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

    delete 'Remove círculo' do
      tags 'Circles'
      produces 'application/json'

      response '204', 'Círculo removido com sucesso' do
        let(:frame) { create(:frame, x_axis: 10000, y_axis: 10000, width: 100, height: 100, total_circles: 0) }
        let(:circle) { create(:circle, frame: frame, x_axis: 10050, y_axis: 10050, diameter: 20) }
        let(:id) { circle.id }

        run_test!
      end

      response '404', 'Círculo não encontrado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('controllers.circles.errors.circle_not_found'))
        end
      end
    end
  end

  describe 'PUT /api/v1/circles/:id' do
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
        expect(response).to have_http_status(:unprocessable_content)

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

  describe 'Circles API' do
    describe 'GET /api/v1/circles' do
      context 'quando buscamos círculos com parâmetros válidos' do
        it 'retorna lista de círculos' do
          frame = Frame.create!(
            x_axis: 7000,
            y_axis: 7000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          Circle.create!(
            frame: frame,
            x_axis: 7050,
            y_axis: 7050,
            diameter: 20
          )

          get '/api/v1/circles', params: {
            center_x: 7050,
            center_y: 7050,
            radius: 50
          }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(1)
        end
      end

      context 'quando buscamos círculos sem parâmetros obrigatórios' do
        it 'retorna erro 422' do
          get '/api/v1/circles'

          expect(response).to have_http_status(:unprocessable_content)
          data = JSON.parse(response.body)
          expect(data['errors']).to include('center_x, center_y e radius são obrigatórios')
        end
      end
    end

    describe 'POST /api/v1/frames/:id/circles' do
      context 'quando criamos um círculo válido' do
        it 'retorna sucesso 201' do
          frame = Frame.create!(
            x_axis: 8000,
            y_axis: 8000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          post "/api/v1/frames/#{frame.id}/circles", params: {
            circle: {
              x_axis: 8050,
              y_axis: 8050,
              diameter: 20
            }
          }

          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq(8050.0)
          expect(data['y_axis']).to eq(8050.0)
          expect(data['diameter']).to eq(20.0)
        end
      end

      context 'quando tentamos criar um círculo inválido' do
        it 'retorna erro 422' do
          frame = Frame.create!(
            x_axis: 9000,
            y_axis: 9000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          post "/api/v1/frames/#{frame.id}/circles", params: {
            circle: {
              x_axis: 9200,
              y_axis: 9050,
              diameter: 20
            }
          }

          expect(response).to have_http_status(:unprocessable_content)
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Círculo deve caber completamente dentro do quadro')
        end
      end
    end

    describe 'DELETE /api/v1/circles/:id' do
      context 'quando deletamos um círculo existente' do
        it 'retorna sucesso 204' do
          frame = Frame.create!(
            x_axis: 10000,
            y_axis: 10000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          circle = Circle.create!(
            frame: frame,
            x_axis: 10050,
            y_axis: 10050,
            diameter: 20
          )

          delete "/api/v1/circles/#{circle.id}"

          expect(response).to have_http_status(:no_content)
        end
      end

      context 'quando tentamos deletar um círculo inexistente' do
        it 'retorna erro 404' do
          delete '/api/v1/circles/999'

          expect(response).to have_http_status(:not_found)
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Círculo não encontrado')
        end
      end
    end
  end
end
