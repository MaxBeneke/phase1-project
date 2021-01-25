class User < ActiveRecord::Base

    has_many :reservations
    has_many :courts, through: :reservations
end
