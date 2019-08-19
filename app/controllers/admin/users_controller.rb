class Admin::UsersController < AdminController
  
  # before_action :initialize_user, only: [:index, :create]
  def index
    @staff = User.all
    @user = User.new
  end

  def create
    @user = User.new 
    create_params = user_params
    @user.assign_attributes(create_params)
            
    if @user.save
      flash[:success] = "Created #{@user.first_name} #{@user.last_name}"
      respond_to do |format|
        format.js
        format.html {redirect_to admin_users_path}
      end
    else
      present_error_messages(@user)
      @staff = User.all
      respond_to do |format|
        format.html {render :index}
      end
    end

  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "#{@user.first_name} #{@user.last_name} Deleted"
    redirect_to admin_users_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update

    @user = User.find(params[:id])

    #We need to pull out the password and password_confirmation and handle them separately
    update_params = user_params
    password = update_params.delete(:password)
    password_confirmation = update_params.delete(:password_confirmation)        
    unless password.blank?
      @user.update_attributes(password: password, password_confirmation: password_confirmation)
    end
    
    @user.update_attributes(update_params)

    if @user.errors.empty?
      flash[:success] = "#{@user.first_name} #{@user.last_name} Updated"
    else
      present_error_messages(@user)
    end

    respond_to do |format|
      format.js
      format.html {redirect_to admin_users_path}
    end

  end

  private
  

  def user_params
    params.require(:user).permit(
      :email, 
      :first_name, 
      :last_name, 
      :password, 
      :password_confirmation
    )
  end

end