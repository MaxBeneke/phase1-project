class User < ActiveRecord::Base

    has_many :reservations
    has_many :courts, through: :reservations

    def self.sign_up(username, password, email)
        User.create(username: username, password: password, email: email)
        
    end

    def joined_reservations
        Reservation.select{|reservation|reservation.secondary_user_id == self.id}
    end
end
