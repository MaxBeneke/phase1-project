class Reservation < ActiveRecord::Base
 
  belongs_to :court
  belongs_to :user

  def joiner 
    User.find(self.secondary_user_id)
  end


end
