class UsersController < ApplicationController
  # GET /home
  def home
    respond_to do |format|
      format.html { render }
      format.json { raise "Oops" }
    end
  end

  def user
    @signed_in = user_signed_in?
    if @signed_in
      @user = current_user
      # @session = current_session
    end

    respond_to do |format|
      format.html { raise "Oops" }
      format.json { render :json => {
          :signed_in => @signed_in,
          :user => @user
          # :session => @session
        } }
    end
  end
end
