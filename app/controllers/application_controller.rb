require 'jwt'
require 'json_web_token'
class ApplicationController < ActionController::Base
    attr_reader :current_user
    
    before_action :allow_cors

    protect_from_forgery unless: -> { request.format.json? }

    def allow_cors
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
        headers["Access-Control-Allow-Headers"] =
            %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")
        
    end

    def handle_cors_options
        head(:ok) if request.request_method == "OPTIONS"
    end


    def authenticate_admin!
        if authenticate_request!
         if @current_user && @current_user.role == 'admin'
            return true
            else
                render json: { status:'failure', reason: 'Not Authorized' }, status: :unauthorized
                return false
            end
        end


    end

    def authenticate_request!
        unless user_id_in_token?
            if http_token.nil?
              Rails.logger.warn("No Authorization header present in the request")
            elsif auth_token.nil?
              Rails.logger.warn("Authorization token could not be decoded")
            else
              Rails.logger.warn("Auth token does not contain user_id. #{auth_token.inspect}")
            end
            render json: { status:'failure', reason: 'Not Authorized' }, status: :unauthorized
            return false
        end
        @current_user = User.find(auth_token[:id])
        return true
      rescue JWT::VerificationError, JWT::DecodeError
        Rails.logger.warn("JWT Token verification failed")
        render json: { status:'failure', reason: 'Not Authorized' }, status: :unauthorized
        return false
    end


    def health
        return render :json => {status: 'success'}, status: 200
    end

  private
    def http_token
        @http_token ||= if request.headers['Authorization'].present?
            request.headers['Authorization'].split(' ').last
        end
    end

    def auth_token
        @auth_token ||= JsonWebToken.get_jwt_decode(http_token)
    end

    def user_id_in_token?
        http_token && auth_token && auth_token[:id]
    end

end
