class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to stamp_cards_path
    end
  end
end
