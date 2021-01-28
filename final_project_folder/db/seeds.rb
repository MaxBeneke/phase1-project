Court.destroy_all
Reservation.destroy_all
User.destroy_all
Court.reset_pk_sequence
Reservation.reset_pk_sequence
User.reset_pk_sequence

user1 = User.create(username: "Quay", password: "fun123", email: "person@gmail.com")
user2 = User.create(username: "Max", password: "Max456", email: "anotherperson@gmail.com")

court1 = Court.create(name: "Court 1")
court2 = Court.create(name: "Court 2")
court3 = Court.create(name: "Court 3")
court4 = Court.create(name: "Court 4")

reservation1 = Reservation.create(user_id: user1.id, court_id: court1.id, open_court: false)
reservation2 = Reservation.create(user_id: user2.id, court_id: court2.id, open_court: true)
reservation3 = Reservation.create(user_id: user1.id, court_id: court3.id, open_court: false)
reservation4 = Reservation.create(user_id: user1.id, court_id: court4.id, open_court: true)
reservation5 = Reservation.create(user_id: user2.id, court_id: court1.id, open_court: false)

puts "👀👀👀👀👀👀 Who seeded the bed? 👀👀👀👀👀👀"