class Base < ApplicationRecord

  validates :base_number, presence: true
  validates :base_name,  presence: true, length: { maximum: 50 }
  validates :base_type,  presence: true, length: { maximum: 50 }

end
