class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "管理者権限が必要です。"
    end
  end
end
