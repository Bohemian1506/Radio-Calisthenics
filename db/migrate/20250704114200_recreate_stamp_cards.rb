class RecreateStampCards < ActiveRecord::Migration[8.0]
  def change
    create_table :stamp_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.datetime :stamped_at, null: false

      t.timestamps
    end

    add_index :stamp_cards, [ :user_id, :date ], unique: true
    add_index :stamp_cards, :date
    add_index :stamp_cards, :stamped_at
  end
end
