class AddSecondaryUserToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :secondary_user_id, :integer

  end
end
