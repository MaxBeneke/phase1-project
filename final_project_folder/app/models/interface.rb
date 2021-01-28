class Interface

    attr_reader :prompt
    attr_accessor :user

    def initialize
        @prompt = TTY::Prompt.new
    end

    def welcome
        system 'clear'
        prompt.select("Welcome to CourtReserver! What would you like to do?") do |menu|
            menu.choice "Log in", -> {user_login_helper}
            menu.choice "Sign up", -> {user_sign_up_helper}
            menu.choice "Exit", -> {exit_helper}
            menu.choice "Help", -> {help_helper}
        end
    end
    
    def user_login_helper
        system 'clear'
        
        username = prompt.ask("Enter username: ")
        password = prompt.mask("Enter password: ")

        ### Check if username and password are in the database ###
        if User.find_by(username: username) && User.find_by(password: password)
            self.user = User.find_by(username: username)
            reservation_screen 
        else puts "Sorry, your username and/or password was incorrect."
            sleep(0.5)
            try_again 
        end
    end

    def try_again
        prompt.select("🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾") do |menu|
            menu.choice "Try again", -> {user_login_helper}
            menu.choice "Exit", ->  {exit_helper}
        end
    end

    def help_helper
        system 'clear'

        puts "This is CourtReserver. It's a helpful app designed to help you reserve time on your favorite tennis court. Create an account and feel free to check all our open reservations. You can even keep your reservation open, if you would like for a user to join you. If you have any questions or concerns, please reach out to our help desk - CourtReserverQM@gmail.com"
        sleep(1.0)

        prompt.select("❓❓❓❓❓❓❓❓❓❓") do |menu|
            menu.choice "Main menu", -> {welcome}
            menu.choice "Exit", ->  {exit_helper}
        end
    end

    def user_sign_up_helper
        system 'clear'

        ### Check database to see if username is already taken ###
        username = prompt.ask("Enter username: ")
        while User.find_by(username: username)
            puts "This username is already taken."
            username = prompt.ask("Enter username: ")
       end

       password = prompt.mask("Enter password: ")
       confirm_password = prompt.mask("Confirm password: ")

       ### Check to see if passwords match ###
       while password != confirm_password 
           puts "Your passwords do not match. Please try again"
                password = prompt.mask("Enter password: ")
                confirm_password = prompt.mask("Confirm password: ")
       end  
       
       email = prompt.ask("Enter email: ")

       ### Adds user to the database and gives them a success message ###
       self.user = User.create(username: username, password: password, email: email)
       system 'clear'
       puts "Success! You're signed in as #{user.username}"
       sleep(1.0)
       reservation_screen
    end

    def exit_helper
        system 'clear'
        puts "Goodbye"
        exit
    end

    def reservation_screen
        system 'clear'
        self.user.reload

        prompt.select("What would you like to do?") do |menu|
            menu.choice "Make a reservation", -> {reservation_creator}
            menu.choice "Join an existing reservation", -> {reservation_joiner}
            menu.choice "Check my reservations", -> {reservation_checker}
            menu.choice "Log out", -> {exit_helper}
        end 
    end
    
    def reservation_creator
        system 'clear'
        self.user.reload
        
        ### Select a court ###
        court_number = prompt.select("Choose a court") do |menu|
            menu.choice "Court 1", 1
            menu.choice "Court 2", 2
            menu.choice "Court 3", 3
            menu.choice "Court 4", 4
            menu.choice "Go back", -> {reservation_screen}
        end
        
        ### Ask if the court is open or closed to other users ###
        open_court = prompt.yes?("Would you like to allow other users to join your reservation?")
        Reservation.create(user_id: self.user.id, court_id: court_number, open_court: open_court)

        puts "You're all set for court #{court_number}."
        sleep(1.0)
        reservation_screen
    end

    def reservation_joiner
        system 'clear'
        self.user.reload
    
        ### Set variable for all joinable reservations. Exclude user's own reservations ###
        joinable_res = Reservation.where.not({open_court: false, user_id: self.user.id}) 
        
        ### Print message showing no available courts ###
        if joinable_res == []
            puts "Sorry there are no courts available to join."
            sleep(1.0)
            reservation_screen
        end
        
        ### Prompt user with joinable reservations and their owner ###
        joined_res = prompt.select("Open courts") do |menu|
            joinable_res.each do |reservation| 
            menu.choice "Court #{reservation.court_id} ------------------ User: #{reservation.user.username}", reservation
            end
            menu.choice "Go back", -> {reservation_screen}
         end 

        joined_res.update(open_court: false, secondary_user_id: user.id)
        
        puts "You've joined #{joined_res.user.username}'s reservation on court #{joined_res.court_id}. Have fun!"
        sleep(2.5)
        reservation_screen
    end

    def reservation_checker
        system 'clear'
        self.user.reload
        
        ### Grammar check. Reservation(s) ###
        if self.user.reservations.count != 1
            puts "You've created #{self.user.reservations.count} reservations." 
        else puts "You've created 1 reservation."
        end
        
        ### Print out list of created reservations. Specify if it's closed, open, or joined ###
        self.user.reservations.each do |reservation| 
            opened = "This court is open to other users"
            if reservation.secondary_user_id
                closed = "#{reservation.joiner.username} has joined your reservation"
            else
                closed = "This court is closed to other users"
            end
            puts "Court: #{reservation.court_id} ------------------ #{reservation.open_court ? opened : closed}"
        end

        puts ""
        print_joined_reservations

        ### Prompts to delete or update reservation ###
        prompt.select("") do |menu|
            menu.choice "Update reservations", -> {update_reservations}
            menu.choice "Delete reservations", -> {delete_reservations}
            menu.choice "Go back", -> {reservation_screen}
        end
    end

    def print_joined_reservations
        
        ### Check for joined_reservations and print them out ###
        puts "----- Joined Reservations -----"
        puts "You've not yet joined any reservations!" if user.joined_reservations == []

        user.joined_reservations.each do |reservation| 
            puts "Court: #{reservation.court_id} ------------------ This reservation belongs to #{reservation.user.username}"
        end
    end

    def update_reservations
        system 'clear'
        self.user.reload

        ### Check for 0 reservations ###
        zero_reservations if user.reservations == [] && user.joined_reservations == []

        ### Check for secondary users and allow user to choose a reservation ###
        updatable_reservation = prompt.select("🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾") do |menu|
            self.user.reservations.each do |reservation|
                if reservation.secondary_user_id == nil
                    menu.choice "Court: #{reservation.court_id} ----------------- This court is #{reservation.open_court ? "open" : "closed"} to other users.", reservation
                end
            end

            ### Add reservations that the user has joined as options ###
            user.joined_reservations.each do |reservation| 
                menu.choice "Court: #{reservation.court_id} ----------------- #{reservation.user.username} owns this reservation", reservation
            end
        end

        ### Allow user to leave a joined reservation or close/open a reservation they own ###
        if updatable_reservation.secondary_user_id && updatable_reservation.secondary_user_id == user.id 
            update = prompt.yes?("Your reservation at court #{updatable_reservation.court_id} is owned by #{updatable_reservation.user.username}. Would you like to leave?")
        else
            update = prompt.yes?("Your reservation at court #{updatable_reservation.court_id} is currently #{updatable_reservation.open_court ? "open" : "closed"} to other users. Would you like to change it?")
        end

        ### Updates database with user input ###
        if update && updatable_reservation.secondary_user_id 
            updatable_reservation.update(secondary_user_id: nil, open_court: true)
        elsif update
            updatable_reservation.open_court ? updatable_reservation.update(open_court: false) : updatable_reservation.update(open_court: true)
        end
        sleep(0.5)
        reservation_checker
    end
         
    def delete_reservations
        system 'clear'
        self.user.reload

        ### Check for 0 reservations ###
        zero_reservations if user.reservations == []

        ### Prompt user to select a reservation to delete ###
        deletable_reservation = prompt.select("👟👟👟👟👟👟👟👟👟") do |menu|
            user.reservations.each do |reservation|
                menu.choice "Delete reservation for court #{reservation.court_id}.", reservation
            end 
            menu.choice "Go back", -> {reservation_checker}   
        end

        ### Confirm with user before deleting ###
        delete = prompt.yes?("Your reservation at court #{deletable_reservation.court_id} will be deleted. Would you like to continue?")

        ### Delete the reservation ###
        if delete
        id = deletable_reservation.court_id
            deletable_reservation.destroy
            puts "Your reservation for court #{id} has been deleted."
        end
        sleep(1.0)
        reservation_screen
    end

    def zero_reservations

    ### Send user to reservation check screen if they have none ###
        puts "Sorry, you own no current reservations."
        sleep(1.5)
        reservation_checker
    end
end
