class Section < ActiveRecord::Base
  belongs_to :user
  has_many :students, through: :followers, source: :student_user

  before_create :assign_code

  def assign_code
    self.code = random_text(6)
  end

private
  CHARS = ("A".."Z").to_a + ("1".."9").to_a - ['O'] # skip 0 and O to avoid mix up
  def random_text(len)
    str = ""
    len.times { |i| str << CHARS[rand(CHARS.length - 1)] }
    str
  end
end