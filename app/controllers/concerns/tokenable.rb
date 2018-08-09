
require 'securerandom'
require 'digest'
require 'date'

module Tokenable
    extend ActiveSupport::Concern 

    def get_new_id
        loop do
        id = SecureRandom.hex(16)
        break id unless User.where(id: id).exists?
        end
    end


    def get_salt()
        SecureRandom.base64(8)
    end

    def get_hashed_password(salt, passwd)
        Digest::SHA2.hexdigest(salt + passwd)
    end

    def password_correct?(user, passwd)
        user.passwd == get_hashed_password(user.salt, passwd)
    end


    def create_new_user(params)
        salt = get_salt()
        id = get_new_id()

        Rails.logger.info("New user id #{id}")
        user = User.create(
                :id => get_new_id(),
                :email => params[:email],
                :name => params[:name],
                :salt => salt,
                :passwd => get_hashed_password(salt, params[:passwd]),
                :role => params[:role])
        user.save()
        return user
    end

  




end