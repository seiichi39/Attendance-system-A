class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overwork_request, :update_overwork_request, :edit_overwork_notice, :update_overwork_notice]
  before_action :logged_in_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :edit_overwork_request]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。" 
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.attributes = (item)
        attendance.save!(context: :validate_one_month)
      end
    end
    flash[:success] = "１ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_overwork_request
    @attendance = @user.attendances.find_by(worked_on: params[:date])
  end

  def update_overwork_request
    overwork_request_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance.update(item)
        flash[:success] = "残業申請を送信しました。"
      else
        flash[:danger] = "残業申請に失敗しました。"
      end
      redirect_to @user
    end
  end

  def edit_overwork_notice
    @request_users = User.where(id: Attendance.where(request_destination: @user.id).select(:user_id))
    @attendance_lists = Attendance.where(request_destination: @user.id)
    if @attendance_lists.nil?
      @attendance_request_count = "0"
    else
      @attendance_request_count = @attendance_lists.count
    end
    @attendance = Attendance.find(params[:id])
  end

  def update_overwork_notice
  end
  
  private
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    def overwork_request_params
      params.require(:user).permit(attendances: [:scheduled_finished_at, :business_processing_content, :next_day, :request_user, :request_status, :request_destination])[:attendances]
    end
    
end
