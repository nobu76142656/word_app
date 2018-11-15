class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "word appへようこそ!"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :password)
      
    end
  
end