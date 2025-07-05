require 'rails_helper'

RSpec.describe 'Stamp Card Image Generation', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by :rack_test
    sign_in_user(user)
    # Create some stamp data
    create(:stamp_card, user: user, date: Date.current)
  end

  describe 'Image generation page' do
    it 'displays the stamp cards page with generation form' do
      visit stamp_cards_path

      # Check page title and basic elements are present
      expect(page).to have_content('📅 スタンプカード')
      expect(page).to have_select('theme-select')
      expect(page).to have_select('format-select')
      expect(page).to have_button('カード画像を生成')
    end
  end
end
