class CreateReservations < ActiveRecord::Migration[5.2]
  def change
    create_table :reservations do|t|
      t.integer :user_id
      t.integer :court_id
      t.boolean :open_court
    end
  end
end
