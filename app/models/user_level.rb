class UserLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :level

  def best?
    Activity.best? best_result
  end

  def finished?
    Activity.finished? best_result
  end

  def passing?
    Activity.passing? best_result
  end
end
