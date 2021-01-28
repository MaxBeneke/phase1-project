class User < ActiveRecord::Base

    has_many :reservations
    has_many :courts, through: :reservations

    def joined_reservations
        Reservation.where(secondary_user_id: self.id)
    end
end
