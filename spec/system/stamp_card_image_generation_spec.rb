require 'rails_helper'

RSpec.describe 'Stamp Card Image Generation', type: :system, js: true do
  let(:user) { create(:user) }
  
  before do
    login_as(user, scope: :user)
    # Create some stamp data
    create(:stamp_card, user: user, date: Date.current)
  end
  
  describe 'Image generation error handling' do
    it 'displays appropriate error message for server errors' do
      # Mock server error
      allow_any_instance_of(StampCardImageService).to receive(:generate).and_raise(StandardError, 'Test error')
      
      visit stamp_cards_path
      
      # Select theme and format
      select 'ブルー', from: 'theme-select'
      select 'PNG (Web用)', from: 'format-select'
      
      # Click generate button
      click_button 'カード画像を生成'
      
      # Check error message is displayed
      expect(page).to have_content('画像生成に失敗しました', wait: 5)
      expect(page).to have_css('.text-danger')
      
      # Button should be re-enabled
      expect(page).to have_button('カード画像を生成', disabled: false)
    end
    
    it 'handles JSON parse errors gracefully' do
      # This would simulate a scenario where server returns HTML instead of JSON
      # In real scenario, this might happen due to middleware errors, routing issues, etc.
      
      visit stamp_cards_path
      
      # Execute JavaScript to test error handling
      page.execute_script(<<-JS)
        // Simulate a response that's not JSON
        const originalFetch = window.fetch;
        window.fetch = function() {
          return Promise.resolve({
            ok: false,
            status: 500,
            headers: {
              get: function(header) {
                if (header === 'content-type') return 'text/html';
                return null;
              }
            }
          });
        };
      JS
      
      click_button 'カード画像を生成'
      
      # Should show server error message
      expect(page).to have_content('サーバーエラーが発生しました', wait: 5)
      
      # Restore original fetch
      page.execute_script('window.fetch = originalFetch;')
    end
    
    it 'handles authentication errors' do
      # Simulate session expiry
      page.execute_script(<<-JS)
        const originalFetch = window.fetch;
        window.fetch = function() {
          return Promise.resolve({
            ok: false,
            status: 401,
            headers: {
              get: function(header) {
                if (header === 'content-type') return 'text/html';
                return null;
              }
            }
          });
        };
      JS
      
      click_button 'カード画像を生成'
      
      expect(page).to have_content('認証が必要です', wait: 5)
      
      page.execute_script('window.fetch = originalFetch;')
    end
  end
  
  describe 'Successful image generation' do
    it 'generates image and shows download button' do
      visit stamp_cards_path
      
      select 'デフォルト', from: 'theme-select'
      select 'PNG (Web用)', from: 'format-select'
      
      click_button 'カード画像を生成'
      
      # Success message
      expect(page).to have_content('画像を生成しました', wait: 5)
      expect(page).to have_css('.text-success')
      
      # Download button appears
      expect(page).to have_link('画像をダウンロード', visible: true)
    end
  end
end