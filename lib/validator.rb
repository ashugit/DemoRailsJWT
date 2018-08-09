class Validator
    def self.is_email_valid(email)
        email_regex = %r{^.+@.+$}
        (email =~ email_regex)
    end

    def self.is_password_valid(password)
        (password.length >= 8)
    end
end