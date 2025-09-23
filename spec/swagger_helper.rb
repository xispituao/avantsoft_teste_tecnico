require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided path and you can preview it at
  # http://localhost:3000/api-docs
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.yaml'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: I18n.t('swagger.info.title'),
        version: I18n.t('swagger.info.version'),
        description: I18n.t('swagger.info.description')
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: I18n.t('swagger.server.development')
        }
      ],
      components: {
        schemas: {
          Frame: {
            type: :object,
            description: I18n.t('swagger.schemas.frame_description'),
            required: [ 'x_axis', 'y_axis', 'width', 'height' ],
            properties: {
              id: {
                type: :integer,
                description: I18n.t('swagger.schemas.field_descriptions.id'),
                example: 1,
                readOnly: true
              },
              x_axis: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.x_axis'),
                example: 100.50,
                minimum: 0
              },
              y_axis: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.y_axis'),
                example: 200.75,
                minimum: 0
              },
              width: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.width'),
                example: 150.00,
                minimum: 0.01
              },
              height: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.height'),
                example: 100.00,
                minimum: 0.01
              },
              total_circles: {
                type: :integer,
                description: I18n.t('swagger.schemas.field_descriptions.total_circles'),
                example: 3,
                minimum: 0,
                readOnly: true
              },
              created_at: {
                type: :string,
                format: :datetime,
                description: I18n.t('swagger.schemas.field_descriptions.created_at'),
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              },
              updated_at: {
                type: :string,
                format: :datetime,
                description: I18n.t('swagger.schemas.field_descriptions.updated_at'),
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              }
            }
          },
          Circle: {
            type: :object,
            description: I18n.t('swagger.schemas.circle_description'),
            required: [ 'x_axis', 'y_axis', 'diameter', 'frame_id' ],
            properties: {
              id: {
                type: :integer,
                description: I18n.t('swagger.schemas.field_descriptions.id'),
                example: 1,
                readOnly: true
              },
              x_axis: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.circle_center_x'),
                example: 125.25,
                minimum: 0
              },
              y_axis: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.circle_center_y'),
                example: 175.50,
                minimum: 0
              },
              diameter: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.diameter'),
                example: 20.00,
                minimum: 0.01
              },
              frame_id: {
                type: :integer,
                description: I18n.t('swagger.schemas.field_descriptions.frame_id'),
                example: 1
              },
              created_at: {
                type: :string,
                format: :datetime,
                description: I18n.t('swagger.schemas.field_descriptions.created_at'),
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              },
              updated_at: {
                type: :string,
                format: :datetime,
                description: I18n.t('swagger.schemas.field_descriptions.updated_at'),
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              }
            }
          },
          FrameMetrics: {
            type: :object,
            description: I18n.t('swagger.schemas.frame_metrics_description'),
            properties: {
              total_circles: {
                type: :integer,
                description: I18n.t('swagger.schemas.field_descriptions.total_circles_count'),
                example: 3,
                minimum: 0
              },
              highest_circle_position: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.highest_position'),
                example: 150.00,
                nullable: true
              },
              lowest_circle_position: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.lowest_position'),
                example: 200.00,
                nullable: true
              },
              leftmost_circle_position: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.leftmost_position'),
                example: 120.00,
                nullable: true
              },
              rightmost_circle_position: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.rightmost_position'),
                example: 180.00,
                nullable: true
              }
            }
          },
          FrameWithMetrics: {
            type: :object,
            description: I18n.t('swagger.schemas.frame_with_metrics_description'),
            allOf: [
              { '$ref' => '#/components/schemas/Frame' },
              {
                type: :object,
                properties: {
                  metrics: { '$ref' => '#/components/schemas/FrameMetrics' }
                }
              }
            ]
          },
          CircleSearchParams: {
            type: :object,
            description: I18n.t('swagger.schemas.circle_search_params_description'),
            required: [ 'center_x', 'center_y', 'radius' ],
            properties: {
              center_x: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.center_x'),
                example: 150.00,
                minimum: 0
              },
              center_y: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.center_y'),
                example: 175.00,
                minimum: 0
              },
              radius: {
                type: :number,
                format: :decimal,
                description: I18n.t('swagger.schemas.field_descriptions.radius'),
                example: 50.00,
                minimum: 0.01
              },
              frame_id: {
                type: :integer,
                description: I18n.t('swagger.schemas.field_descriptions.frame_id_optional'),
                example: 1
              }
            }
          },
          Error: {
            type: :object,
            description: I18n.t('swagger.schemas.error_description'),
            required: [ 'errors' ],
            properties: {
              errors: {
                type: :array,
                description: I18n.t('swagger.schemas.field_descriptions.errors_list'),
                items: {
                  type: :string,
                  example: I18n.t('models.circle.errors.circle_fits_in_frame')
                },
                example: [ I18n.t('models.circle.errors.circle_fits_in_frame'), I18n.t('models.circle.errors.no_circle_overlap') ]
              }
            }
          },
          ValidationError: {
            type: :object,
            description: I18n.t('swagger.schemas.validation_error_description'),
            properties: {
              errors: {
                type: :object,
                description: I18n.t('swagger.schemas.field_descriptions.errors_by_field'),
                additionalProperties: {
                  type: :array,
                  items: { type: :string }
                },
                example: {
                  'x_axis' => [ I18n.t('activerecord.errors.models.circle.attributes.x_axis.blank') ],
                  'diameter' => [ I18n.t('activerecord.errors.models.circle.attributes.diameter.greater_than', count: 0) ]
                }
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
