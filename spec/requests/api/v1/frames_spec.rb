require 'swagger_helper'

RSpec.describe 'Api::V1::Frames', type: :request do
  path '/api/v1/frames' do
    post 'Cria quadro' do
      tags 'Frames'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :frame, in: :body, schema: {
        type: :object,
        properties: {
          frame: {
            type: :object,
            properties: {
              x_axis: { type: :number, example: 0 },
              y_axis: { type: :number, example: 0 },
              width: { type: :number, example: 100 },
              height: { type: :number, example: 100 },
              circles_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    x_axis: { type: :number },
                    y_axis: { type: :number },
                    diameter: { type: :number },
                    _destroy: { type: :boolean },
                    id: { type: :integer }
                  }
                }
              }
            },
            required: [ 'x_axis', 'y_axis', 'width', 'height' ]
          }
        }
      }

      response '201', 'Quadro criado com sucesso' do
        schema '$ref' => '#/components/schemas/Frame'

        let(:frame) do
          {
            frame: {
              x_axis: 1000,
              y_axis: 1000,
              width: 100,
              height: 100
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq(1000.0)
          expect(data['y_axis']).to eq(1000.0)
          expect(data['width']).to eq(100.0)
          expect(data['height']).to eq(100.0)
        end
      end

      response '422', 'Erro de validação' do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) do
          {
            frame: {
              x_axis: 0,
              y_axis: 0,
              width: -100,
              height: 100
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include("Width deve ser maior que 0")
        end
      end
    end
  end

  path '/api/v1/frames/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Mostra quadro' do
      tags 'Frames'
      produces 'application/json'

      response '200', 'Detalhes do quadro' do
        schema '$ref' => '#/components/schemas/FrameWithMetrics'

        let(:frame) { create(:frame, x_axis: 2000, y_axis: 2000, width: 100, height: 100, total_circles: 0) }
        let(:id) { frame.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(frame.id)
          expect(data['metrics']['total_circles']).to eq(0)
        end
      end

      response '404', 'Quadro não encontrado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('controllers.frames.errors.frame_not_found'))
        end
      end
    end

    delete 'Remove quadro' do
      tags 'Frames'
      produces 'application/json'

      response '204', 'Quadro removido com sucesso' do
        let(:frame) { create(:frame, x_axis: 3000, y_axis: 3000, width: 100, height: 100, total_circles: 0) }
        let(:id) { frame.id }

        run_test!
      end

      response '422', 'Erro ao remover quadro com círculos' do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) { create(:frame, x_axis: 4000, y_axis: 4000, width: 100, height: 100, total_circles: 0) }
        let(:id) { frame.id }

        before do
          create(:circle, frame: frame, x_axis: 4050, y_axis: 4050, diameter: 20)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('services.frame_service.errors.cannot_delete_with_circles'))
        end
      end

      response '404', 'Quadro não encontrado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('controllers.frames.errors.frame_not_found'))
        end
      end
    end
  end

  path '/api/v1/frames/{id}/circles' do
    parameter name: :id, in: :path, type: :integer

    post 'Adiciona círculo ao quadro' do
      tags 'Frames'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              x_axis: { type: :number, example: 50 },
              y_axis: { type: :number, example: 50 },
              diameter: { type: :number, example: 20 }
            },
            required: [ 'x_axis', 'y_axis', 'diameter' ]
          }
        }
      }

      response '201', 'Círculo criado com sucesso' do
        schema '$ref' => '#/components/schemas/Circle'

        let(:frame) { create(:frame, x_axis: 5000, y_axis: 5000, width: 100, height: 100, total_circles: 0) }
        let(:id) { frame.id }
        let(:circle) do
          {
            circle: {
              x_axis: 5050,
              y_axis: 5050,
              diameter: 20
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq(5050.0)
          expect(data['y_axis']).to eq(5050.0)
          expect(data['diameter']).to eq(20.0)
          expect(data['frame_id']).to eq(frame.id)
        end
      end

      response '422', 'Erro de validação' do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) { create(:frame, x_axis: 6000, y_axis: 6000, width: 100, height: 100, total_circles: 0) }
        let(:id) { frame.id }
        let(:circle) do
          {
            circle: {
              x_axis: 5050,
              y_axis: 5050,
              diameter: 200
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('models.circle.errors.circle_fits_in_frame'))
        end
      end

      response '404', 'Quadro não encontrado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }
        let(:circle) do
          {
            circle: {
              x_axis: 50,
              y_axis: 50,
              diameter: 20
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('controllers.frames.errors.frame_not_found'))
        end
      end
    end
  end

  describe 'Frames API' do
    describe 'POST /api/v1/frames' do
      context 'quando criamos um frame válido' do
        it 'retorna sucesso 201' do
          post '/api/v1/frames', params: {
            frame: {
              x_axis: 1000,
              y_axis: 1000,
              width: 100,
              height: 100,
              total_circles: 0
            }
          }

          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq(1000.0)
          expect(data['y_axis']).to eq(1000.0)
          expect(data['width']).to eq(100.0)
          expect(data['height']).to eq(100.0)
        end
      end

      context 'quando tentamos criar um frame inválido' do
        it 'retorna erro 422' do
          post '/api/v1/frames', params: {
            frame: {
              x_axis: 1000,
              y_axis: 1000,
              width: -100,
              height: 100,
              total_circles: 0
            }
          }

          expect(response).to have_http_status(:unprocessable_content)
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Width deve ser maior que 0')
        end
      end
    end

    describe 'GET /api/v1/frames/:id' do
      context 'quando buscamos um frame existente' do
        it 'retorna sucesso 200' do
          frame = Frame.create!(
            x_axis: 2000,
            y_axis: 2000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          get "/api/v1/frames/#{frame.id}"

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data['id']).to eq(frame.id)
          expect(data['x_axis']).to eq(2000.0)
        end
      end
    end

    describe 'DELETE /api/v1/frames/:id' do
      context 'quando deletamos um frame sem círculos' do
        it 'retorna sucesso 204' do
          frame = Frame.create!(
            x_axis: 3000,
            y_axis: 3000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          delete "/api/v1/frames/#{frame.id}"

          expect(response).to have_http_status(:no_content)
        end
      end

      context 'quando tentamos deletar um frame com círculos' do
        it 'retorna erro 422' do
          frame = Frame.create!(
            x_axis: 4000,
            y_axis: 4000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          Circle.create!(
            frame: frame,
            x_axis: 4050,
            y_axis: 4050,
            diameter: 20
          )

          delete "/api/v1/frames/#{frame.id}"

          expect(response).to have_http_status(:unprocessable_content)
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Não é possível excluir quadro com círculos associados')
        end
      end
    end

    describe 'POST /api/v1/frames/:id/circles' do
      context 'quando criamos um círculo válido em um frame' do
        it 'retorna sucesso 201' do
          frame = Frame.create!(
            x_axis: 5000,
            y_axis: 5000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          post "/api/v1/frames/#{frame.id}/circles", params: {
            circle: {
              x_axis: 5050,
              y_axis: 5050,
              diameter: 20
            }
          }

          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['x_axis']).to eq(5050.0)
          expect(data['y_axis']).to eq(5050.0)
          expect(data['diameter']).to eq(20.0)
        end
      end

      context 'quando tentamos criar um círculo inválido' do
        it 'retorna erro 422' do
          frame = Frame.create!(
            x_axis: 6000,
            y_axis: 6000,
            width: 100,
            height: 100,
            total_circles: 0
          )

          post "/api/v1/frames/#{frame.id}/circles", params: {
            circle: {
              x_axis: 6200,
              y_axis: 6050,
              diameter: 20
            }
          }

          expect(response).to have_http_status(:unprocessable_content)
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Círculo deve caber completamente dentro do quadro')
        end
      end
    end
  end
end
