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
        end
    end

end
