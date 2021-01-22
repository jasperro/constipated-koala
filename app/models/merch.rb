#:nodoc:
class Merch < ApplicationRecord
  self.table_name = "merchandise"
  
  belongs_to :member

  validates :order_id, presence: true
  validates :quantity, presence: true

  validates :item_entry_id, presence: true
  validates :item_size, presence: true
  validates :item_color, presence: true

  enum status: { preOrder: 1, ordered: 2, shipping: 3, readyForPickup: 4, finished: 5 }
  
  is_impressionable
end
