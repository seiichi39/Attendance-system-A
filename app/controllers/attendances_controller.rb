class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_attendance_change_request, :update_attendance_change_request, :edit_attendance_change_request, :edit_attendance_change_notice, :update_attendance_change_notice, 
                                  :edit_overwork_request, :update_overwork_request, :edit_overwork_notice, :update_overwork_notice, :index_attendance_log, :edit_one_month_request, :update_one_month_request,
                                  :edit_one_month_notice, :update_one_month_notice]
  before_action :logged_in_user, only: [:update, :edit_attendance_change_request, :update_attendance_change_request]
  before_action :admin_or_correct_user, only: [:update, :edit_attendance_change_request, :update_attendance_change_request]
  before_action :set_one_month, only: [:edit_attendance_change_request, :edit_overwork_request, :edit_one_month_request]
  
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
    redirect_to attendances_edit_one_month_request_user_path(current_user)
  end

  def edit_one_month_request
    @worked_sum = @attendances.where.not(started_at: nil).count
    @attendance = Attendance.where(user_id: @user.id).find_by(worked_on: @first_day)
    @attendance_one_month_lists = Attendance.where("(one_month_request_destination = ?) AND (one_month_request_status = ?)", @user.id, "申請中")
    if @attendance_one_month_lists.nil?
      @attendance_one_month_request_count = "0"
    else
      @attendance_one_month_request_count = @attendance_one_month_lists.count
    end
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

  def update_one_month_request
    one_month_request_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance.update_attributes(item)
        flash[:success] = "１ヶ月の勤怠情報を申請しました。"
      else
        flash[:danger] = "勤怠情報の申請に失敗しました。"
      end
    end
    redirect_to attendances_edit_one_month_request_user_path(current_user)
  end

  def edit_one_month_notice
    @request_users = User.where(id: Attendance.where(one_month_request_destination: @user.id).select(:user_id))
    @attendance_lists = Attendance.where("(one_month_request_destination = ?) AND (one_month_request_status = ?)", @user.id, "申請中")
    @attendance = Attendance.new
  end

  def update_one_month_notice
    update_judgement = "false"
    one_month_notice_params.each do |id,item|
      attendance = Attendance.find(id)
      if item[:one_month_change] == "true"
        if item[:one_month_request_status] == "承認"
        elsif item[:one_month_request_status] == "否認"
        elsif item[:one_month_request_status] == "なし" 
        else
        end
        item[:one_month_change] = "false"
        attendance.update_attributes(item)
        update_judgement = "true"
        flash[:success] = "上長確認しました。"
      else
      end
    end
    unless update_judgement == "true"
      flash[:danger] = "上長確認する場合、変更ボタンにチェックを入れてください。"
    end
    redirect_to attendances_edit_one_month_request_user_path(current_user)
  end

  def edit_attendance_change_request
  end

  def update_attendance_change_request
    attendance_change_request_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance.update_attributes(item)
        flash[:success] = "１ヶ月の勤怠情報を申請しました。"
      else
        flash[:danger] = "勤怠情報の申請に失敗しました。"
      end
    end
    redirect_to attendances_edit_one_month_request_user_path(current_user)
  end

  def edit_attendance_change_notice
    @request_users = User.where(id: Attendance.where(modification_request_destination: @user.id).select(:user_id))
    @attendance_lists = Attendance.where("(modification_request_destination = ?) AND (modification_request_status = ?)", @user.id, "申請中")
    @attendance = Attendance.new
  end

  def update_attendance_change_notice
    update_judgement = "false"
    attendance_change_notice_params.each do |id,item|
      attendance = Attendance.find(id)
      if item[:modification_change] == "true"
        if item[:modification_request_status] == "承認"
        elsif item[:modification_request_status] == "否認"
          item[:started_at] = attendance.started_at
          item[:finished_at] = attendance.finished_at
          item[:before_change_started_at] = attendance.before_change_started_at
          item[:before_change_finished_at] = attendance.before_change_finished_at
          item[:change_attendance_approval_date] = nil
        elsif item[:modification_request_status] == "なし" 
          item[:started_at] = attendance.started_at
          item[:finished_at] = attendance.finished_at
          item[:before_change_started_at] = nil
          item[:before_change_finished_at] = nil
          item[:after_change_started_at] = nil
          item[:modification_request_destination] = nil
          item[:change_attendance_approval_date] = nil
        else
        end
        item[:modification_change] = "false"
        attendance.update_attributes(item)
        update_judgement = "true"
        flash[:success] = "上長確認しました。"
      else
      end
    end
    unless update_judgement == "true"
      flash[:danger] = "上長確認する場合、変更ボタンにチェックを入れてください。"
    end
    redirect_to attendances_edit_one_month_request_user_path(current_user)
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
        flash[:success] = "上長確認しました。"
      end
    end
    unless update_judgement == "true"
      flash[:danger] = "上長確認する場合、変更ボタンにチェックを入れてください。"
    end
    redirect_to attendances_edit_one_month_request_user_path(current_user)
  end
  
  def index_attendance_log
    @q = Attendance.ransack(params[:q])
    @attendance_lists = @q.result(distinct: true).where(user_id: @user.id).where.not(change_attendance_approval_date: nil)
    @attendance = Attendance.new
  end
  
  private
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    # 所属長承認申請関連のストロングパラメータとして使用
    def one_month_request_params
      params.require(:user).permit(attendances: [:one_month_request_status, :one_month_request_destination])[:attendances]
    end
    
    # 所属長承認申請関連のストロングパラメータとして使用
    def one_month_notice_params
      params.require(:user).permit(attendances: [:one_month_request_status, :one_month_change])[:attendances]
    end   

    # 勤怠変更申請関連のストロングパラメータとして使用
    def attendance_change_request_params
      params.require(:user).permit(attendances: [:modification_request_status, :before_change_started_at, :initial_started_at, :before_change_finished_at,
                                                :initial_finished_at, :after_change_started_at, :after_change_finished_at, :modification_next_day, :note, :modification_request_destination])[:attendances]
    end

    # 勤怠変更申請承認関連のストロングパラメータとして使用
    def attendance_change_notice_params
      params.require(:user).permit(attendances: [:modification_request_status, :modification_change, :change_attendance_approval_date, :started_at, :finished_at, :before_change_started_at, :before_change_finished_at])[:attendances]
    end

    # 残業申請関連のストロングパラメータとして使用
    def overwork_request_params
      params.require(:user).permit(attendances: [:scheduled_finished_at, :business_processing_content, :overwork_next_day, :request_user, :overwork_request_status, :overwork_request_destination])[:attendances]
    end

    # 残業申請承認関連のストロングパラメータとして使用
    def overwork_notice_params
      params.require(:user).permit(attendances: [:scheduled_finished_at, :business_processing_content, :overwork_change, :overwork_request_status, :over_work_time])[:attendances]
    end
    
end
