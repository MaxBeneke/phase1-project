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

    def try_again
        prompt.select("🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾") do |menu|
            menu.choice "Try again", -> {user_login_helper}
            menu.choice "Exit", ->  {exit_helper}
        end
    end

    def user_login_helper
        system 'clear'
        
        username = prompt.ask("Enter username: ")
        password = prompt.mask("Enter password: ")

        if User.find_by(username: username) && User.find_by(password: password)
            self.user = User.find_by(username: username)
            reservation_screen 
        else puts "Sorry, your username and/or password was incorrect."
            sleep(0.5)
            try_again 
        end
    end

    def help_helper
        
        puts "This is CourtReserver. It's a helpful app designed to help you reserve time on your favorite tennis court. Create an account and feel free to check all our open reservations. You can even keep your reservation open, if you would like for a user to join you. If you have any questions or concerns, please reach out to our help desk - CourtReserverQM@gmail.com"
        sleep(1.0)

        prompt.select("❓❓❓❓❓❓❓❓❓❓") do |menu|
            menu.choice "Main menu", -> {welcome}
            menu.choice "Exit", ->  {exit_helper}
        end
    end

    def user_sign_up_helper
        system 'clear'
        self.user.reload

        username = prompt.ask("Enter username: ")
        while User.find_by(username: username)
            puts "This username is already taken."
            username = prompt.ask("Enter username: ")
       end

       password = prompt.mask("Enter password: ")
       confirm_password = prompt.mask("Confirm password: ")

       while password != confirm_password 
           puts "Your passwords do not match. Please try again"
                password = prompt.mask("Enter password: ")
                confirm_password = prompt.mask("Confirm password: ")
       end  
       
       email = prompt.ask("Enter email: ")
       
       self.user = User.create(username: username, password: password, email: email)
       
       reservation_screen
    end

    def exit_helper
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

        court_number = prompt.select("Choose a court") do |menu|
            menu.choice "Court 1", 1
            menu.choice "Court 2", 2
            menu.choice "Court 3", 3
            menu.choice "Court 4", 4
            menu.choice "Go back", -> {reservation_screen}
        end

        open_court = prompt.yes?("Would you like to allow other users to join your reservation?")
        Reservation.create(user_id: self.user.id, court_id: court_number, open_court: open_court)

        puts "You're all set for court #{court_number}."
        sleep(2.0)
        reservation_screen
    end

    def reservation_joiner
        system 'clear'
        self.user.reload
    
        joinable_court = Reservation.where.not({open_court: false, user_id: self.user.id}) 
      
        if joinable_court == []
            puts "Sorry there are no courts available to join."
            sleep(1.0)
            reservation_screen
        end
    
        joined_court = prompt.select("Open courts") do |menu|
            joinable_court.each do |reservation| 
            menu.choice "Court #{reservation.court_id} ------------------ User: #{reservation.user.username}", reservation
            end
            menu.choice "Go back", -> {reservation_screen}
         end 

        joined_court.update(open_court: false)
        
        puts "You've joined #{joined_court.user.username}'s reservation on court #{joined_court.court_id}. Have fun!"
        sleep(2.5)
        reservation_screen
    end

    def reservation_checker
        system 'clear'
        self.user.reload

        if self.user.reservations.count != 1
            puts "You have #{self.user.reservations.count} reservations." 
        else puts "You have 1 reservation."
        end

        self.user.reservations.each do |reservation| 
            puts "Court: #{reservation.court_id} ------------------ This court is #{reservation.open_court ? "open" : "closed"} to other users"
        end

        prompt.select("") do |menu|
            menu.choice "Update reservations", -> {update_reservations}
            menu.choice "Delete reservations", -> {delete_reservations}
            menu.choice "Go back", -> {reservation_screen}
        end
    end

    def update_reservations
        system 'clear'
        self.user.reload
           
        if self.user.reservations == []
            puts "Sorry you have no current reservations."
            sleep(1.5)
            reservation_checker
        end

        updatable_reservation = prompt.select("🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾🎾") do |menu|
            self.user.reservations.each do |reservation|
            menu.choice "Court: #{reservation.court_id} ----------------- This court is #{reservation.open_court ? "open" : "closed"} to other users.", reservation
            end
        end

        update = prompt.yes?("Your reservation at court #{updatable_reservation.court_id} is currently #{updatable_reservation.open_court ? "open" : "closed"} to other users. Would you like to change it?")
        
        if update 
            updatable_reservation.open_court ? updatable_reservation.update(open_court: false) : updatable_reservation.update(open_court: true)
        end
        reservation_checker
    end
         
        def delete_reservations
        system 'clear'
        self.user.reload
        if self.user.reservations == []
            puts "Sorry you have no current reservations."
            sleep(1.5)
            reservation_checker
        end
    
        deletable_reservation = prompt.select("👟👟👟👟👟👟👟👟👟") do |menu|
            self.user.reservations.each do |reservation|
                menu.choice "Delete reservation for court #{reservation.court_id}.", reservation
            end  
        end
        
        delete = prompt.yes?("Your reservation at court #{deletable_reservation.court_id} will be deleted. Would you like to continue?")

        if delete
        id = deletable_reservation.court_id
            deletable_reservation.destroy
            puts "Your reservation for court #{id} has been deleted."
        end
        sleep(1.0)
        reservation_screen
    end
end
