require 'rails_helper'

RSpec.describe StampCardsController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST #generate_image' do
    context 'when not authenticated' do
      it 'returns JSON error for JSON requests' do
        post :generate_image, params: { year: 2025, month: 7 }, format: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
      end
    end

    context 'when authenticated' do
      before { sign_in user }

      context 'with valid parameters' do
        before do
          # Create stamp data for the user
          create(:stamp_card, user: user, date: Date.new(2025, 7, 1))
        end

        it 'returns success JSON' do
          post :generate_image, params: { year: 2025, month: 7, theme: 'default', image_format: 'png' }, format: :json

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('application/json')

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('success')
        end
      end

      context 'with invalid parameters' do
        it 'returns error JSON for invalid month' do
          post :generate_image, params: { year: 2025, month: 13 }, format: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to include('application/json')

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to include('スタンプデータがありません')
        end
      end

      context 'when server error occurs' do
        before do
          allow_any_instance_of(StampCardImageService).to receive(:generate).and_raise(StandardError, 'Test error')
        end

        it 'returns error JSON' do
          create(:stamp_card, user: user, date: Date.new(2025, 7, 1))
          post :generate_image, params: { year: 2025, month: 7 }, format: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to include('application/json')

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to be_present
        end
      end

      context 'with HTML format request masquerading as JSON' do
        it 'handles content type mismatch gracefully' do
          request.headers['Accept'] = 'text/html'
          post :generate_image, params: { year: 2025, month: 7 }, format: :json

          expect(response.content_type).to include('application/json')
        end
      end

      context 'when ActionController::UnknownFormat occurs' do
        it 'handles format errors gracefully' do
          create(:stamp_card, user: user, date: Date.new(2025, 7, 1))

          # Simulate a request without proper format (not XHR, not JSON)
          request.headers['Accept'] = 'text/plain'
          post :generate_image, params: { year: 2025, month: 7 }

          # Should redirect for non-XHR, non-JSON requests
          expect(response).to redirect_to(stamp_cards_path(year: 2025, month: 7))
        end
      end
    end
  end

  describe 'error handling for non-JSON requests' do
    before { sign_in user }

    it 'redirects HTML requests on error' do
      post :generate_image, params: { year: 2025, month: 7 }, format: :html

      expect(response).to redirect_to(stamp_cards_path(year: 2025, month: 7))
    end
  end
end
