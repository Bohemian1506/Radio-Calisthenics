class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to statistics_path
    end
  end
end
