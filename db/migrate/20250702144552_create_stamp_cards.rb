class CreateStampCards < ActiveRecord::Migration[8.0]
  def change
    create_table :stamp_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.datetime :stamped_at

      t.timestamps
    end
  end
end
