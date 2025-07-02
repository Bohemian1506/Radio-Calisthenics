class CreateAdminSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_settings do |t|
      t.string :setting_name
      t.string :setting_value

      t.timestamps
    end
  end
end
