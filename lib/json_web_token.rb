require 'jwt'
class JsonWebToken
    def self.get_jwt_encode(payload)
        JWT.encode(payload, Rails.application.credentials.jwt_secret)
    end

    def self.get_jwt_decode(token)
        HashWithIndifferentAccess.new(JWT.decode(token, Rails.application.credentials.jwt_secret, "H256")[0])
        rescue
            nil
    end
end