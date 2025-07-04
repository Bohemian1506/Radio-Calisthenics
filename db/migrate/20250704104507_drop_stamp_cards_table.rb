class DropStampCardsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :stamp_cards
  end
end
