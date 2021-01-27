class Interface

    attr_reader :prompt
    attr_accessor :user

    def initialize
        @prompt = TTY::Prompt.new
    end

    def welcome
        prompt.select("Welcome to CourtReserver! What would you like to do?") do |menu|
            menu.choice "Login", -> {user_login_helper}
            menu.choice "Sign up", -> {user_sign_up_helper}
            menu.choice "Exit", -> {exit_helper}
            menu.choice "Help", -> {help_helper}
        end
    end


    def try_again
        prompt.select("------------------------------------") do |menu|
            menu.choice "Try again", -> {user_login_helper}
            menu.choice "Exit", ->  {exit_helper}
        end
    end

    def user_login_helper
      username = prompt.ask("Enter username: ")
      password = prompt.ask("Enter password: ")

        if User.all.find{|user| user.username == username} && User.all.find{|user| user.password == password}
            self.user = User.find_by(username: username)
        reservation_screen 
        else puts "Sorry your username and/or password was incorrect."
        sleep(0.5)
        try_again 
        end
    end

    def help_helper
        
        puts "This is CourtReserver. It's a helpful app designed to help you reserve time on your favorite tennis court. Create a account and feel free to check all our open reservations. You can even keep your reservation open, if you would like for a user to join you. If you have any questions or concerns please reach out our help desk @ CourtReserverQM@gmail.com"
        sleep(1.0)

        prompt.select("------------------------------------") do |menu|
            menu.choice "Main menu", -> {welcome}
            menu.choice "Exit", ->  {exit_helper}

        end
    end

    def user_sign_up_helper
        username = prompt.ask("Enter username: ")
       while User.find_by(username: username)
            puts "This username is already taken."
            username = prompt.ask("Enter username: ")
       end

        
       password = prompt.ask("Enter password: ")
       confirm_password = prompt.ask("Confirm password: ")

       while password != confirm_password 
           puts "Your passwords do not match. Please try again"
                password = prompt.ask("Enter password: ")
                confirm_password = prompt.ask("Confirm password: ")
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
        prompt.select("What would you like to do?") do |menu|
            menu.choice "Make a reservation", -> {reservation_creator}
            menu.choice "Join a existing reservation", -> {reservation_joiner}
            menu.choice "Check reservations", -> {reservation_checker}
            menu.choice "Log out", -> {exit_helper}
        end 
    
    end
    
    def reservation_creator
        court_number = prompt.select("Choose a court") do |menu|
            menu.choice "Court 1", 1
            menu.choice "Court 2", 2
            menu.choice "Court 3", 3
            menu.choice "Court 4", 4
            menu.choice "Go back", -> {reservation_screen}
        end
      open_court = prompt.yes?("Would you like to allow other users to join your reservation?")
      Reservation.create(user_id: self.user.id, court_id: court_number, open_court: open_court)
    end

    def reservation_joiner
    
    joinable_court = Reservation.where.not({open_court: false, user_id: self.user.id}) 
      
    if joinable_court == []
        puts "Sorry there are no courts available to join."
        sleep(1.0)
        reservation_screen
    end
    
   joined_court = prompt.select("Open courts") do |menu|
        joinable_court.each do |reservation| 
            menu.choice "Court #{reservation.court_id} ------ User: #{reservation.user.username}", reservation
        end
       menu.choice "Go back", -> {reservation_screen}


    end 

    joined_court.update(open_court: false)
    puts "Should be able to join reservation"
    end





    def reservation_checker
       if self.user.reservations.count != 1
        puts "You have #{self.user.reservations.count} reservations." 
            else puts "You have 1 reservation."
        end


        open_court = "This court is open to other users"
        closed_court = "This court is closed to other users"
        self.user.reservations.each do |reservation| 
            puts "Court: #{reservation.court_id} ------ #{reservation.open_court ? open_court : closed_court}"
            end

        prompt.select("") do |menu|
            menu.choice "Update/Delete reservations", -> {update_reservations}
            menu.choice "Go back", -> {reservation_screen}
        end
        end

        def update_reservations
            open_court = "This court is open to other users"
            closed_court = "This court is closed to other users"
            updatable_reservation =  prompt.select("----") do |menu|
                    self.user.reservations.each do |reservation|
                    menu.choice "Court: #{reservation.court_id} ------ #{reservation.open_court ? open_court : closed_court}", reservation
                    end
                    binding.pry
                end
            prompt.select("Your reservation at court #{updatable_reservation.court_id} is currently 
            #{updatable_reservation.open_court ? "open" : "closed"} to other users.") do |menu|
                menu.choice "Change court status(open/closed)", -> {!updatable_reservation.open_court}
                menu.choice "Delete reservation", -> {updatable_reservation.destroy}
                menu.choice "Go back", -> {reservation_checker}
                reservation_checker
        
        end

         end

end
