class UsersController < ApplicationController
  #GET /users
  def index
    @title = "User management"
    @page = get_page
    user_form

    sort_params = sort_params(params)
    @revert = sort_params[:revert_dir]
    
    if params[:query].present?
      @query = params[:query].strip
    end

    @type  = params[:type]
    @users = User.md0_users.paginate_user :query => @query, :type => @type,
                                :page => (@page || '1').to_i, :per_page => PerPage,
                                :order => "#{sort_params[:field]} #{sort_params[:dir]} "
                              
    render :file => "users/_list_users.html.erb", :layout => false if request.xhr?
  end

  #POST /users/:id
  def destroy
    user = User.find(params[:id])
    if user == current_user
      flash["msg-error"] = "You can't delete yourself. First log in as another user and delete youself."
    elsif user.reports.exists?
      flash["msg-error"] = "User #{user.user_name} can't be deleted because it already sent some reports."
    else
      user.destroy
      flash["msg-error"] = "User #{user.user_name} has been removed"
    end
    redirect_to users_path(:page => params[:page])
  end

  def create_new

    attributes = params.slice :user_name, :email, :password, :phone_number, :role, :id, :intended_place_code, :status
   
    attributes[:password_confirmation] = attributes[:password]
    #attributes[:status] = User.from_status(attributes[:status])


    @user = User.new attributes

    if @user.save
      flash["msg-notice"] = "Successfully created"
      redirect_to users_path
    else
      flash["msg-error"] = "Failed to create"
      redirect_to users_path(attributes.except(:password))
    end
  end

  def show
    @user = User.find(params[:id].to_i)
    render :layout => false
  end

  def edit
    @user = User.find params[:id]
    render :layout => false
  end

  def update
    attributes = params.slice :user_name, :email, :password, :phone_number, :role, :intended_place_code, :status
    attributes[:password_confirmation] = attributes[:password]

    attributes[:status] = User.from_status(attributes[:status])

    @user = User.find params[:id]
  

    if(@user.update_params attributes)
      @user.reload #reload the user with its related model(place model)
      @msg = {"msg-notice" => "Update successfully."}
      render :show, :layout => false
    else
      @msg = {"msg-error" => "Failed to update."}
      @user[:intended_place_code] =  params[:intended_place_code]
      render :edit, :layout => false
    end
  end

  #GET /users/csv_template
  def csv_template
    column_headers = "Name,Email,Phone,Password,Place code,Role"
    send_data column_headers, :type => 'text/csv', :filename => 'users-template.csv'
  end

  def reports
    @user = User.find params[:id]
    @reports = Report.where(:sender_id => @user.id).paginate :page => get_page, :per_page => 10, :order => 'id desc'
    @report_id = params[:report_id].to_i
    render :layout => false
  end

  def upload_csv
    @file_name = params[:user][:csvfile].original_filename
    if @file_name.scan(/\.csv$/i).size == 0
       render  "invalid_csv_format.html.erb"
    else
       file = get_user_csv_path @file_name
       FileUtils.mv params[:user][:csvfile].path, file
       @users = UserImporter.simulate file
       render "upload_csv.html.erb"
    end
  end

  def confirm_import
    file_name = params[:file]
    file = get_user_csv_path(file_name)
    count = UserImporter.import(file)
    flash[:notice] = "#{count} users have been added "
    redirect_to :controller => :users
  end

  private

  def get_user_csv_path file_name
     File.join Rails.root, "tmp", file_name
  end

  def user_form
    if(params[:user_name].present?)
      attributes = params.slice :user_name, :email, :password, :phone_number, :role, :id, :intended_place_code
      attributes[:password_confirmation] = attributes[:password]
      @user = User.new attributes
      @user.valid?
      @user.intended_place_code = params[:intended_place_code]
    else
      @user = User.new
    end
  end
 
end
