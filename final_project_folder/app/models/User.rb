class User < ActiveRecord::Base

    has_many :reservations
    has_many :courts, through: :reservations

    def self.sign_up(username, password, email)
        User.create(username: username, password: password, email: email)
        
    end


end
