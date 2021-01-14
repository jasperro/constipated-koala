#:nodoc:
class Group < ApplicationRecord
  belongs_to :member

  validates :id, presence: true
  validates :order_id, presence: true
  validates :item_id, presence: true
  validates :price, presence: true

  enum status: { preOrder: 1, ordered: 2, shipping: 3, readyForPickup: 4, finished: 5 }
  
  is_impressionable
end