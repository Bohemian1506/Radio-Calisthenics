class Admin::SettingsController < Admin::BaseController
  def index
    @participation_start_time = AdminSetting.participation_start_time
    @participation_end_time = AdminSetting.participation_end_time
  end

  def update
    setting_name = params[:setting_name]
    setting_value = params[:setting_value]

    if valid_setting?(setting_name, setting_value)
      AdminSetting.set_value(setting_name, setting_value)
      redirect_to admin_settings_path, notice: t('controllers.admin.settings.updated')
    else
      redirect_to admin_settings_path, alert: t('controllers.admin.settings.invalid')
    end
  end

  private

  def valid_setting?(name, value)
    case name
    when "participation_start_time", "participation_end_time"
      valid_time_format?(value)
    else
      false
    end
  end

  def valid_time_format?(time_str)
    Time.parse(time_str)
    true
  rescue ArgumentError
    false
  end
end
