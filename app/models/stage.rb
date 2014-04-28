class Stage < ActiveRecord::Base
  has_many :script_levels, -> { order("position ASC") }
  belongs_to :script
  acts_as_list scope: :script

  validates_uniqueness_of :name, scope: :script_id
end
