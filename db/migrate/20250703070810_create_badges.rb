class CreateBadges < ActiveRecord::Migration[8.0]
  def change
    create_table :badges do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :icon, null: false
      t.string :badge_type, null: false
      t.json :conditions, null: false
      t.boolean :active, null: false, default: true
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :badges, :badge_type
    add_index :badges, :active
    add_index :badges, :sort_order
  end
end