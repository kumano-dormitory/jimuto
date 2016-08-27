class Request < ApplicationRecord
  belongs_to :shift
  belongs_to :user
  has_many :request_solutions
  has_many :solutions, through: :request_solutions

  # userのpoint
  # pointが少ない人が入った時に高くなるように
  def score_by_point
    1.to_f/ user.point
  end
end
