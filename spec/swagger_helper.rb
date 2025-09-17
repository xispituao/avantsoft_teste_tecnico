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
        title: 'Avantsoft API V1',
        version: 'v1',
        description: 'API para gerenciamento de quadros e círculos'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Servidor de desenvolvimento'
        }
      ],
      components: {
        schemas: {
          Frame: {
            type: :object,
            description: 'Representa um quadro retangular no sistema',
            required: ['x_axis', 'y_axis', 'width', 'height'],
            properties: {
              id: { 
                type: :integer, 
                description: 'Identificador único do quadro',
                example: 1,
                readOnly: true
              },
              x_axis: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada X do canto superior esquerdo do quadro',
                example: 100.50,
                minimum: 0
              },
              y_axis: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada Y do canto superior esquerdo do quadro',
                example: 200.75,
                minimum: 0
              },
              width: { 
                type: :number, 
                format: :decimal,
                description: 'Largura do quadro em centímetros',
                example: 150.00,
                minimum: 0.01
              },
              height: { 
                type: :number, 
                format: :decimal,
                description: 'Altura do quadro em centímetros',
                example: 100.00,
                minimum: 0.01
              },
              total_circles: { 
                type: :integer, 
                description: 'Número total de círculos dentro do quadro',
                example: 3,
                minimum: 0,
                readOnly: true
              },
              created_at: { 
                type: :string, 
                format: :datetime,
                description: 'Data e hora de criação do quadro',
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              },
              updated_at: { 
                type: :string, 
                format: :datetime,
                description: 'Data e hora da última atualização do quadro',
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              }
            }
          },
          Circle: {
            type: :object,
            description: 'Representa um círculo dentro de um quadro',
            required: ['x_axis', 'y_axis', 'diameter', 'frame_id'],
            properties: {
              id: { 
                type: :integer, 
                description: 'Identificador único do círculo',
                example: 1,
                readOnly: true
              },
              x_axis: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada X do centro do círculo',
                example: 125.25,
                minimum: 0
              },
              y_axis: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada Y do centro do círculo',
                example: 175.50,
                minimum: 0
              },
              diameter: { 
                type: :number, 
                format: :decimal,
                description: 'Diâmetro do círculo em centímetros',
                example: 20.00,
                minimum: 0.01
              },
              frame_id: { 
                type: :integer, 
                description: 'ID do quadro ao qual o círculo pertence',
                example: 1
              },
              created_at: { 
                type: :string, 
                format: :datetime,
                description: 'Data e hora de criação do círculo',
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              },
              updated_at: { 
                type: :string, 
                format: :datetime,
                description: 'Data e hora da última atualização do círculo',
                example: '2025-09-17T02:42:13.630Z',
                readOnly: true
              }
            }
          },
          FrameMetrics: {
            type: :object,
            description: 'Métricas calculadas dos círculos dentro de um quadro',
            properties: {
              total_circles: { 
                type: :integer, 
                description: 'Número total de círculos no quadro',
                example: 3,
                minimum: 0
              },
              highest_circle_position: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada Y do círculo mais alto (menor valor Y)',
                example: 150.00,
                nullable: true
              },
              lowest_circle_position: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada Y do círculo mais baixo (maior valor Y)',
                example: 200.00,
                nullable: true
              },
              leftmost_circle_position: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada X do círculo mais à esquerda (menor valor X)',
                example: 120.00,
                nullable: true
              },
              rightmost_circle_position: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada X do círculo mais à direita (maior valor X)',
                example: 180.00,
                nullable: true
              }
            }
          },
          FrameWithMetrics: {
            type: :object,
            description: 'Quadro com suas métricas de círculos',
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
            description: 'Parâmetros para busca de círculos por raio',
            required: ['center_x', 'center_y', 'radius'],
            properties: {
              center_x: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada X do centro da busca',
                example: 150.00,
                minimum: 0
              },
              center_y: { 
                type: :number, 
                format: :decimal,
                description: 'Coordenada Y do centro da busca',
                example: 175.00,
                minimum: 0
              },
              radius: { 
                type: :number, 
                format: :decimal,
                description: 'Raio de busca em centímetros',
                example: 50.00,
                minimum: 0.01
              },
              frame_id: { 
                type: :integer, 
                description: 'ID do quadro para filtrar círculos (opcional)',
                example: 1
              }
            }
          },
          Error: {
            type: :object,
            description: 'Resposta de erro da API',
            required: ['errors'],
            properties: {
              errors: {
                type: :array,
                description: 'Lista de mensagens de erro',
                items: { 
                  type: :string,
                  example: 'Círculo deve caber completamente dentro do quadro'
                },
                example: ['Círculo deve caber completamente dentro do quadro', 'Círculo não pode tocar outro círculo no mesmo quadro']
              }
            }
          },
          ValidationError: {
            type: :object,
            description: 'Erro de validação com detalhes específicos',
            properties: {
              errors: {
                type: :object,
                description: 'Erros organizados por campo',
                additionalProperties: {
                  type: :array,
                  items: { type: :string }
                },
                example: {
                  'x_axis' => ['não pode estar em branco'],
                  'diameter' => ['deve ser maior que 0']
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