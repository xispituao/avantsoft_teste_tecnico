# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'I18n Support', type: :request do
  before { host! 'localhost:3000' }

  describe 'Locale switching' do
    let(:frame) { create(:frame) }

    context 'with PT-BR locale' do
      it 'returns error messages in Portuguese' do
        get "/frames/999999", headers: { 'Accept-Language': 'pt-BR' }

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['error']).to eq('Quadro não encontrado')
      end

      it 'returns validation errors in Portuguese' do
        post "/frames",
             params: { frame: { x_axis: 0, y_axis: 0, width: -1, height: 100 } },
             headers: { 'Accept-Language': 'pt-BR' },
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        data = JSON.parse(response.body)
        expect(data['errors']).to be_present
      end

      it 'returns missing parameters error in Portuguese' do
        get "/circles", headers: { 'Accept-Language': 'pt-BR' }

        expect(response).to have_http_status(:bad_request)
        data = JSON.parse(response.body)
        expect(data['error']).to include('Parâmetros obrigatórios faltando')
      end
    end

    context 'with EN locale' do
      it 'returns error messages in English' do
        get "/frames/999999", headers: { 'Accept-Language': 'en' }

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['error']).to eq('Frame not found')
      end

      it 'returns validation errors in English' do
        post "/frames",
             params: { frame: { x_axis: 0, y_axis: 0, width: -1, height: 100 } },
             headers: { 'Accept-Language': 'en' },
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        data = JSON.parse(response.body)
        expect(data['errors']).to be_present
      end

      it 'returns missing parameters error in English' do
        get "/circles", headers: { 'Accept-Language': 'en' }

        expect(response).to have_http_status(:bad_request)
        data = JSON.parse(response.body)
        expect(data['error']).to include('Missing required parameters')
      end
    end

    context 'with locale parameter' do
      it 'uses locale from query parameter' do
        get "/frames/999999?locale=en"

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['error']).to eq('Frame not found')
      end

      it 'query parameter overrides header' do
        get "/frames/999999?locale=en", headers: { 'Accept-Language': 'pt-BR' }

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['error']).to eq('Frame not found')
      end
    end

    context 'with unsupported locale' do
      it 'falls back to default locale (pt-BR)' do
        get "/frames/999999", headers: { 'Accept-Language': 'fr' }

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['error']).to eq('Quadro não encontrado')
      end
    end
  end
end
