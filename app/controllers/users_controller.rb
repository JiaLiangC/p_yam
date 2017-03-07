class UsersController < ApplicationController
  
  #
  def new
    @user = User.new
  end

# 注册
  def create
    @user = User.new(user_params)

    account = account_type(user_params[:account])
    if account == 'mobile'
      @user.mobile_verified = true
      @user.mobile = user_params[:account].to_s
    elsif account == 'email'
      @user.email = user_params[:account].to_s
    end


    if @user.save
      if account  == 'email'
        UserMailer.account_activation(@user).deliver_now
        flash[:info] = "please check your email to activate your account"
        redirect_to root_url
      end
      redirect_back_or @user
    else
      render "new"
    end
  end

  def edit
  end


  def account_activation
    user = User.find_by_email(params[:email])
    if user && !user.activated_by_email? && user.authenticated?(:email_activation, params[:id])
      user.activate(:email)
      log_in(user)
      flash[:message] = "account activated"
      redirect_back_or user
    else
      flash[:message] = "invalid activation link"
      redirect_to root_url
    end
  end

  def show

  end



  private
    def user_params
      params.require(:user).permit(:account,:name,:email,:phone,:password,:password_confirmation,:verify_code)
    end

end
