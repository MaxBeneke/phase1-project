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
            menu.choice "Make a reservation", -> {reservation_maker}
            menu.choice "Check reservations", -> {reservation_checker}
            menu.choice "Log out", -> {exit_helper}
        end 
    
    end

    def reservation_maker
        prompt.select("Create or join reservation") do |reservation|
            reservation.choice "Create a new reservation", -> {reservation_creator}
            reservation.choice "Join existing reservation", -> {reservation_joiner}
        end
 
    end
    
    def reservation_creator
        court_number = prompt.select("Choose a court") do |menu|
            menu.choice "Court 1", 1
            menu.choice "Court 2", 2
            menu.choice "Court 3", 3
            menu.choice "Court 4", 4
        end
      open_court = prompt.yes?("Would you like to allow other users to join your reservation?")
      Reservation.create(user_id: self.user.id, court_id: court_number, open_court: open_court)
    end

    def reservation_joiner
    
    joinable_court = Reservation.where.not({open_court: false, user_id: self.user.id}) 
    binding.pry
    if joinable_court == nil
        puts "Sorry there are no courts available to join."
        reservation_screen
    end
    
   joined_court = prompt.select("Open courts") do |menu|
        joinable_court.each do |reservation| 
            menu.choice "Court #{reservation.court_id} ------ User: #{reservation.user.username}", reservation
        end
       
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
    
    


    end
        





end
