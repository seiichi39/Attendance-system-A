class UsersController < ApplicationController
  before_action :set_user,only:[:show, :edit, :update, :destroy, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :update_basic_info]
  # before_action :admin_or_correct_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
    @users = User.paginate(page: params[:page]).search(params[:search]).order(id: "ASC")
    @search_user = params[:search]
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @attendance_overwork_lists = Attendance.where("(overwork_request_destination = ?) AND (overwork_request_status = ?)", @user.id, "申請中")
    if @attendance_overwork_lists.nil?
      @attendance_overwork_request_count = "0"
    else
      @attendance_overwork_request_count = @attendance_overwork_lists.count
    end
    @attendance_modification_lists = Attendance.where("(modification_request_destination = ?) AND (modification_request_status = ?)", @user.id, "申請中")
    if @attendance_modification_lists.nil?
      @attendance_modification_request_count = "0"
    else
      @attendance_modification_request_count = @attendance_modification_lists.count
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  def go_work
    @users = User.all.includes(:attendances)
  end

  def import
    if params[:csv_file].blank?
      redirect_to(users_url, alert: 'インポートするCSVファイルを選択してください')
    else
      num = User.import(params[:csv_file])
      redirect_to(users_url, notice: "#{num.to_s}件のユーザー情報を追加 / 更新しました")
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(
        :name, :email, :department, :employee_number, :uid, :basic_work_time,:designed_work_start_time,
        :designed_work_end_time, :password, :password_confirmation)
    end
    
end
