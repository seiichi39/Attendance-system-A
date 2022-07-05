class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_attendance_change, :update_attendance_change, :edit_overwork_request, :update_overwork_request, :edit_overwork_notice, :update_overwork_notice]
  before_action :logged_in_user, only: [:update, :edit_attendance_change, :update_attendance_change]
  before_action :admin_or_correct_user, only: [:update, :edit_attendance_change, :update_attendance_change]
  before_action :set_one_month, only: [:edit_attendance_change, :edit_overwork_request]
  
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
  
  def edit_attendance_change
  end

  def update_attendance_change
    attendance_change_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance.update(item)
        flash[:success] = "１ヶ月の勤怠情報を申請しました。"
      else
        flash[:danger] = "勤怠情報の申請に失敗しました。"
      end
    end
    redirect_to @user
  end

  def edit_overwork_request
    @attendance = @user.attendances.find_by(worked_on: params[:date])
  end

  def update_overwork_request
    attendance_change_params.each do |id, item|
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
    @request_users = User.where(id: Attendance.where(overwork_request_destination: @user.id).select(:user_id))
    @attendance_lists = Attendance.where("(overwork_request_destination = ?) AND (overwork_change = ?)", @user.id, false)
    @attendance = Attendance.find(params[:id])
  end

  def update_overwork_notice
    update_judgement = "false"
    overwork_notice_params.each do |id,item|
      attendance = Attendance.find(id)
      if overwork_notice_params[id][:overwork_change] == "true"
        if overwork_notice_params[id][:overwork_request_status] == "承認"
          attendance.overwork_request_status = "承認"
        elsif overwork_notice_params[id][:overwork_request_status] == "否認"
          attendance.overwork_request_status = "否認"
        else overwork_notice_params[id][:overwork_request_status] == "なし" 
          attendance.overwork_request_status = "なし"
        end
        attendance.update(item)
        update_judgement = "true"
      end
      flash[:success] = "上長確認しました。"
    end
    unless update_judgement == "true"
      flash[:danger] = "上長確認する場合、変更ボタンにチェックを入れてください。"
    end
    redirect_to user_path(@user)
  end 
  
  private
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    def attendance_change_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :modification_next_day, :modification_request_status,
                                                 :modification_change, :modification_request_destination, :before_change_started_at,
                                                 :before_change_finished_at, :after_change_started_at, :after_change_finished_at,
                                                 :initial_started_at, :initial_finished_at, :change_attendance_approval_date])[:attendances]
    end

    def overwork_request_params
      params.require(:user).permit(attendances: [:scheduled_finished_at, :business_processing_content, :overwork_next_day, :request_user, :overwork_request_status, :overwork_request_destination])[:attendances]
    end

    def overwork_notice_params
      params.require(:user).permit(attendances: [:scheduled_finished_at, :business_processing_content, :overwork_change, :overwork_request_status, :over_work_time])[:attendances]
    end
    
end
