require 'swagger_helper'

RSpec.describe 'Api::V1::Frames', type: :request do
  path '/api/v1/frames' do
    post I18n.t('swagger.operations.frames.create') do
      tags I18n.t('swagger.tags.frames')
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
              circles: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    x_axis: { type: :number },
                    y_axis: { type: :number },
                    diameter: { type: :number }
                  }
                }
              },
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
            required: ['x_axis', 'y_axis', 'width', 'height']
          }
        }
      }

      response '201', I18n.t('swagger.responses.success.frame_created') do
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
          expect(data['x_axis']).to eq('1000.0')
          expect(data['y_axis']).to eq('1000.0')
          expect(data['width']).to eq('100.0')
          expect(data['height']).to eq('100.0')
        end
      end

      response '422', I18n.t('swagger.responses.errors.validation_error') do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) do
          {
            frame: {
              x_axis: 0,
              y_axis: 0,
              width: 100,
              height: 100
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('models.frame.errors.no_frame_overlap'))
        end
      end
    end
  end

  path '/api/v1/frames/{id}' do
    parameter name: :id, in: :path, type: :integer

    get I18n.t('swagger.operations.frames.show') do
      tags I18n.t('swagger.tags.frames')
      produces 'application/json'

      response '200', I18n.t('swagger.responses.success.frame_details') do
        schema '$ref' => '#/components/schemas/FrameWithMetrics'

        let(:frame) { create(:frame, x_axis: 2000, y_axis: 2000) }
        let(:id) { frame.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(frame.id)
          expect(data['metrics']['total_circles']).to eq(0)
        end
      end

      response '404', I18n.t('swagger.responses.errors.frame_not_found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('controllers.frames.errors.frame_not_found'))
        end
      end
    end

    delete I18n.t('swagger.test_operations.remove_frame') do
      tags I18n.t('swagger.test_tags.frames')
      produces 'application/json'

      response '204', I18n.t('swagger.test_responses.success.frame_removed') do
        let(:frame) { create(:frame, x_axis: 3000, y_axis: 3000) }
        let(:id) { frame.id }

        run_test!
      end

      response '422', I18n.t('swagger.test_responses.success.frame_with_circles_error') do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) { create(:frame, x_axis: 4000, y_axis: 4000) }
        let(:id) { frame.id }

        before do
          create(:circle, frame: frame)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include(I18n.t('services.frame_service.errors.cannot_delete_with_circles'))
        end
      end

      response '404', I18n.t('swagger.responses.errors.frame_not_found') do
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

    post I18n.t('swagger.test_responses.success.circle_added') do
      tags I18n.t('swagger.test_tags.frames')
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
            required: ['x_axis', 'y_axis', 'diameter']
          }
        }
      }

      response '201', I18n.t('swagger.test_responses.success.circle_created') do
        schema '$ref' => '#/components/schemas/Circle'

        let(:frame) { create(:frame, x_axis: 5000, y_axis: 5000) }
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
          expect(data['x_axis']).to eq('5050.0')
          expect(data['y_axis']).to eq('5050.0')
          expect(data['diameter']).to eq('20.0')
          expect(data['frame_id']).to eq(frame.id)
        end
      end

      response '422', I18n.t('swagger.responses.errors.validation_error') do
        schema '$ref' => '#/components/schemas/Error'

        let(:frame) { create(:frame, x_axis: 6000, y_axis: 6000) }
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

      response '404', I18n.t('swagger.responses.errors.frame_not_found') do
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
end
