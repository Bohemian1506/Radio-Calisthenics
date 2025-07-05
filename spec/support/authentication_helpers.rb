module AuthenticationHelpers
  def sign_in_user(user)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :system
end
