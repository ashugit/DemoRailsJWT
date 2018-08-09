require 'validator'
require 'securerandom'
require 'json_web_token'
class UsersController < ApplicationController
  include Tokenable
  before_action :authenticate_admin!, :except => [:register, :authenticate]

  def index
    users = User.all
    return render :json =>users.to_json, status: 200
  end

  def show
    user = User.find(params[:id])
    if user
      return render :json => user.as_json, status: 200
    else
      return render :json => {status: 'failure', reason: 'user not found'}, status: 404
    end
  end


  def destroy
    user = User.find(params[:id])
    if !user.nil?
      user.destroy
      return render :json => {status: 'success'}, status: 200
    else
      return render :json => {status: 'failure', reason: 'user not found'}, status: 404
    end
  end

  def create
    [:email, :passwd, :name].each_with_object(params) do |key, obj|
      obj.require(key)
      rescue ActionController::ParameterMissing
        return render :json => {status: 'failure', reason: "signup field #{key} is missing."}, status: 403
    end
    

    if !Validator.is_email_valid(params[:email])
      return render :json => {status: 'failure', reason: 'email is not valid'}, status: 403
    end    

    user = User.find_by_email(params[:email])
    if user
      return render :json => {status: 'failure', reason: "email #{params[:email]} is already created, please use another email."}, status: 403
    end

    params[:passwd] = SecureRandom.alphanumeric(8)
    # Admin cannot set a password
    # if !Validator.is_password_valid(params[:passwd])
    #   return render :json => {status: 'failure', reason: 'password is too short'}, status: 403
    # end    

    new_user = create_new_user(params)

    if new_user.nil?
      return render :json => {  status: 'failure', 
                                reason: 'could not create the user',
                                profile: user.pic }, status: 400
    else
      return render :json => {  status: 'success', 
                                name: new_user.name,
                                email: new_user.email,
                                role: new_user.role,
                                created_at: new_user.created_at}, status: 200
    end
    
  end


  def register

    [:email, :passwd, :name].each_with_object(params) do |key, obj|
      obj.require(key)
      rescue ActionController::ParameterMissing
        return render :json => {status: 'failure', reason: "signup field #{key} is missing."}, status: 403
    end

    if !Validator.is_email_valid(params[:email])
      return render :json => {status: 'failure', reason: 'email is not valid'}, status: 403
    end    

    user = User.find_by_email(params[:email])
    if user
      return render :json => {status: 'failure', reason: "email #{params[:email]} is already created and not available now."}, status: 403
    end

    if !Validator.is_password_valid(params[:passwd])
      return render :json => {status: 'failure', reason: 'password is too short'}, status: 403
    end    

    if params[:email].split("@").last == 'demo.com'
      params[:role] = "admin"
    else
      params[:role] = "user"
    end

    new_user = create_new_user(params)

    if new_user.nil?
      return render :json => {  status: 'failure', 
                                reason: 'could not create the user',
                                profile: user.pic }, status: 400
    else

      token = JsonWebToken.get_jwt_encode({ :id => new_user.id, 
                                    :email => new_user.email,
                                    :role => new_user.role})

      return render :json => {  status: 'success', 
                                token: token,
                                name: new_user.name,
                                email: new_user.email,
                                role: new_user.role}, status: 200
    end
  end

  def update
    user = Users.find(params[:id])
  end


  def authenticate
    [:email, :passwd].each_with_object(params) do |key, obj|
      obj.require(key)
    end

    user = User.find_by_email(params[:email])
    if user.nil?
      Rails.logger.warn("could not find user with the given email id #{params[:email]}")
      return render :json => {status: 'failure', reason: "user with email not found"}, status: 403
    end

    if password_correct?(user, params[:passwd])
      # user.last_login = Time.now
      # user.save()
      token = JsonWebToken.get_jwt_encode({ :id => user.id, 
                               :email => user.email,
                               :role => user.role})

      return render :json => {  status: 'success', 
                               token: token,
                               name: user.name,
                               email: user.email}, status: 200
    else   
      return render :json => { status: 'failure', 
                               reason: "password did not match"},
                              status: 403
    end
  end              


  

end
