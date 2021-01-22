class Merchandise < ActiveRecord::Migration[6.0]
  def change
    create_table :merchandise, id: false do |t|
      t.string :order_id, :null => false
      t.integer :quantity, :null => false, default: 1

      t.string :item_entry_id, :null => false
      t.string :item_size, :null => false
      t.string :item_color, :null => false

      t.string :status, :null => false

      t.belongs_to :member, :null => false

      t.timestamps
    end

    add_index :merchandise, [:member_id, :order_id, :item_entry_id], :unique => true
  end
end
