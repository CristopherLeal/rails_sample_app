class SessionsController < ApplicationController
  def new
  end

  def create
      user = User.find_by_email params[:session][:email].downcase
      if user && user.authenticate( params[:session][:password])
        log_in user
        redirect_to user
      else
        # method now assert that the message will be shown just once
        flash.now[:danger] = "Invalid email/password combination"
        render 'new'
      end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
