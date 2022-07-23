class AttendancesController < ApplicationController
  before_action :set_user, only: [:new, :edit_attendance_change_request, :update_attendance_change_request, :edit_attendance_change_request, :edit_attendance_change_notice, :update_attendance_change_notice, 
                                  :edit_overwork_request, :update_overwork_request, :edit_overwork_notice, :update_overwork_notice, :index_attendance_log, :edit_one_month_request, :update_one_month_request,
                                  :edit_one_month_notice, :update_one_month_notice]
  before_action :logged_in_user, only: [:update, :edit_attendance_change_request, :update_attendance_change_request]
  before_action :admin_or_correct_user, only: [:update, :edit_attendance_change_request, :update_attendance_change_request]
  before_action :set_one_month, only: [:edit_attendance_change_request, :edit_overwork_request, :edit_overwork_notice, :edit_one_month_request]
  before_action :non_admin_user, only: [:edit_one_month_request, :edit_attendance_change_request]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。" 

  require 'csv'

  # csv出力用のアクションとして定義
  def new
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    @attendance = Attendance.new
    @attendances = Attendance.where(user_id: @user.id).where(worked_on: one_month).order(worked_on: "ASC")
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end
  
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
      if item[:one_month_request_destination].present? 
        if attendance.update_attributes(item)
          flash[:success] = "１ヶ月分の勤怠情報を申請しました。"
        else
          flash[:danger] = "勤怠情報の申請に失敗しました。"
        end
      else
        flash[:danger] = "上長を選択してください。"
      end
      redirect_to attendances_edit_one_month_request_user_path(current_user, date: @first_day)
    end
  end

  def edit_one_month_notice
    @request_users = User.where(id: Attendance.where("(one_month_request_destination = ?) AND (one_month_request_status = ?)", @user.id, "申請中").select(:user_id))
    @attendance_lists = Attendance.where("(one_month_request_destination = ?) AND (one_month_request_status = ?)", @user.id, "申請中").order(worked_on: "ASC")
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
        item[:one_month_change] = nil
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
    ActiveRecord::Base.transaction do
      attendance_change_request_params.each do |id, item|
        attendance = Attendance.find(id) 
          if item[:modification_request_destination].present?
            if item[:initial_started_at].present? && item[:initial_finished_at].present? 
              if item[:modification_next_day] == "true"
                year = (item[:worked_on].to_date + 1).year 
                month = (item[:worked_on].to_date + 1).month
                day = (item[:worked_on].to_date + 1).day 
              else
                year = (item[:worked_on].to_date).year 
                month = (item[:worked_on].to_date).month
                day = (item[:worked_on].to_date).day
              end
              hour = (item[:initial_finished_at].to_time).hour
              min = (item[:initial_finished_at].to_time).min
              year1 = (item[:worked_on].to_date).year 
              month1 = (item[:worked_on].to_date).month
              day1 = (item[:worked_on].to_date).day
              hour1 = (item[:initial_started_at].to_time).hour
              min1 = (item[:initial_started_at].to_time).min
              item[:initial_finished_at] = Time.new(year, month, day, hour, min, 0,).to_time
              item[:initial_started_at] = Time.new(year1, month1, day1, hour1, min1, 0,).to_time
            elsif item[:before_change_started_at].present? && item[:before_change_finished_at].present?
              if item[:modification_next_day] == "true"
                year = (item[:worked_on].to_date + 1).year 
                month = (item[:worked_on].to_date + 1).month
                day = (item[:worked_on].to_date + 1).day 
              else
                year = (item[:worked_on].to_date).year 
                month = (item[:worked_on].to_date).month
                day = (item[:worked_on].to_date).day
              end
              hour = (item[:before_change_finished_at].to_time).hour
              min = (item[:before_change_finished_at].to_time).min
              year1 = (item[:worked_on].to_date).year 
              month1 = (item[:worked_on].to_date).month
              day1 = (item[:worked_on].to_date).day
              hour1 = (item[:before_change_started_at].to_time).hour
              min1 = (item[:before_change_started_at].to_time).min
              item[:before_change_finished_at] = Time.new(year, month, day, hour, min, 0,).to_time
              item[:before_change_started_at] = Time.new(year1, month1, day1, hour1, min1, 0,).to_time
            elsif item[:after_change_started_at].present? && item[:after_change_finished_at].present?
              if item[:modification_next_day] == "true"
                year = (item[:worked_on].to_date + 1).year 
                month = (item[:worked_on].to_date + 1).month
                day = (item[:worked_on].to_date + 1).day 
              else
                year = (item[:worked_on].to_date).year 
                month = (item[:worked_on].to_date).month
                day = (item[:worked_on].to_date).day
              end
              hour = (item[:after_change_finished_at].to_time).hour
              min = (item[:after_change_finished_at].to_time).min
              year1 = (item[:worked_on].to_date).year 
              month1 = (item[:worked_on].to_date).month
              day1 = (item[:worked_on].to_date).day
              hour1 = (item[:after_change_started_at].to_time).hour
              min1 = (item[:after_change_started_at].to_time).min
              item[:after_change_finished_at] = Time.new(year, month, day, hour, min, 0,).to_time
              item[:after_change_started_at] = Time.new(year1, month1, day1, hour1, min1, 0,).to_time            
            end
            attendance.update_attributes!(item)
          end
        if item[:modification_request_destination].blank? && item[:initial_started_at].present? && item[:initial_finished_at].present?
          flash[:warning] = "上長を選択してないため、申請できていない日付があります。"
        end
      end
    end
      flash[:success] = "勤怠変更を申請しました。"
      redirect_to attendances_edit_one_month_request_user_path(current_user)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあったため、申請をキャンセルしました。"
    redirect_to attendances_edit_one_month_request_user_path(current_user)
  end

  def edit_attendance_change_notice
    @request_users = User.where(id: Attendance.where(modification_request_destination: @user.id).where(modification_request_status: "申請中").select(:user_id))
    @attendance_lists = Attendance.where("(modification_request_destination = ?) AND (modification_request_status = ?)", @user.id, "申請中").order(worked_on: "ASC")
    @attendance = Attendance.new
  end

  def update_attendance_change_notice
    update_judgement = "false"
    attendance_change_notice_params.each do |id,item|
      attendance = Attendance.find(id)
      if item[:modification_change] == "true"
        if item[:modification_request_status] == "承認"
        elsif item[:modification_request_status] == "否認"
          item[:started_at] = nil
          item[:finished_at] = nil
          item[:change_attendance_approval_date] = nil
          if attendance.before_change_started_at.present? && attendance.after_change_started_at.present?
            item[:initial_started_at] = attendance.initial_started_at
            item[:initial_finished_at] = attendance.initial_finished_at
            item[:before_change_started_at] = attendance.before_change_started_at
            item[:before_change_finished_at] = attendance.before_change_finished_at
            item[:after_change_started_at] = nil
            item[:after_change_finished_at] = nil                        
          elsif attendance.before_change_started_at.present? && attendance.after_change_started_at.blank?
            item[:initial_started_at] = attendance.initial_started_at
            item[:initial_finished_at] = attendance.initial_finished_at
            item[:before_change_started_at] = nil
            item[:before_change_finished_at] = nil
          else
            item[:initial_started_at] = nil
            item[:initial_finished_at] = nil
          end
        elsif item[:modification_request_status] == "なし" 
          item[:started_at] = nil
          item[:finished_at] = nil
          item[:initial_started_at] = nil
          item[:initial_finished_at] = nil          
          item[:before_change_started_at] = nil
          item[:before_change_finished_at] = nil
          item[:after_change_started_at] = nil
          item[:after_change_finished_at] = nil
          item[:modification_request_destination] = nil
          item[:change_attendance_approval_date] = nil
          item[:modification_next_day] = nil
          item[:note] = nil
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
      if overwork_request_params[id][:scheduled_finished_at].present? && overwork_request_params[id][:overwork_request_destination].present?
        if overwork_request_params[id][:overwork_next_day] == "true"
          year = (overwork_request_params[id][:worked_on].to_date + 1).year 
          month = (overwork_request_params[id][:worked_on].to_date + 1).month
          day = (overwork_request_params[id][:worked_on].to_date + 1).day
        else
          year = (overwork_request_params[id][:worked_on].to_date).year
          month = (overwork_request_params[id][:worked_on].to_date).month
          day = (overwork_request_params[id][:worked_on].to_date).day
        end
          hour = (overwork_request_params[id][:scheduled_finished_at].to_time).hour
          min = (overwork_request_params[id][:scheduled_finished_at].to_time).min
          year1 = (overwork_request_params[id][:worked_on].to_date).year  
          month1 = (overwork_request_params[id][:worked_on].to_date).month
          day1 = (overwork_request_params[id][:worked_on].to_date).day
          hour1 = @user.designed_work_end_time.to_datetime.hour
          min1 = @user.designed_work_end_time.to_datetime.min
        scheduled_finished_at = Time.new(year, month, day, hour, min, 0,).to_time
        designed_work_end_time = Time.new(year1, month1, day1, hour1, min1, 0,).to_time
        item[:over_work_time] = overwork_time(scheduled_finished_at - designed_work_end_time)
        if attendance.update_attributes(item)
          flash[:success] = "残業申請を送信しました。"
        else
          flash[:danger] = "残業申請に失敗しました。"
        end
      elsif overwork_request_params[id][:scheduled_finished_at].blank? && overwork_request_params[id][:overwork_request_destination].blank?
        flash[:danger] = "終了予定時間を入力してください。上長を選択してください。"
      elsif overwork_request_params[id][:scheduled_finished_at].blank?
        flash[:danger] = "終了予定時間を入力してください。"
      elsif overwork_request_params[id][:overwork_request_destination].blank?
        flash[:danger] = "上長を選択してください。"
      end
      redirect_to attendances_edit_one_month_request_user_path(current_user)
    end
  end

  def edit_overwork_notice
    @request_users = User.where(id: Attendance.where(overwork_request_destination: @user.id).select(:user_id))
    @attendance_lists = Attendance.where("(overwork_request_status = ?) AND (overwork_request_destination = ?) AND (overwork_change = ?)", "申請中", @user.id, false).order(worked_on: "ASC")
    @attendance = Attendance.find(params[:id])
  end

  def update_overwork_notice
    update_judgement = "false"
    overwork_notice_params.each do |id,item|
      attendance = Attendance.find(id)
      if overwork_notice_params[id][:overwork_change] == "true"
        if overwork_notice_params[id][:overwork_request_status] == "承認"
          item[:overwork_request_status] = "承認"
        elsif overwork_notice_params[id][:overwork_request_status] == "否認"
          item[:overwork_request_status] = "否認"
        elsif overwork_notice_params[id][:overwork_request_status] == "なし" 
          item[:overwork_request_status] = "なし"
          item[:scheduled_finished_at] = nil
          item[:business_processing_content] = nil
          item[:over_work_time] = nil
          item[:overwork_next_day] = nil
          item[:overwork_request_destination] = nil
        else
        end
        item[:overwork_change] = "false"
        attendance.update_attributes(item)
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
    @attendance_lists = @q.result(distinct: true).where(user_id: @user.id).where(modification_request_status: "承認").order(worked_on: "ASC")
    @attendance = Attendance.new
  end
  
  private

    # 勤怠一覧表をCSVで出力するために使用
    def send_attendances_csv(attendances)
      require 'time'
      csv_data = CSV.generate do |csv|
        column_names = %w(日付 出社 退社)
        csv << column_names
        attendances.each do |attendance|
          column_values = [
            attendance.worked_on,
            attendance.started_at_time,
            attendance.finished_at_time,
          ]
          csv << column_values
        end
      end
      send_data(csv_data, filename: "勤怠一覧表.csv")
    end
  
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
      params.require(:user).permit(attendances: [:worked_on, :started_at, :finished_at, :modification_request_status, :before_change_started_at, :initial_started_at, :before_change_finished_at,
                                                :initial_finished_at, :after_change_started_at, :after_change_finished_at, :modification_next_day, :note, :modification_request_destination])[:attendances]
    end

    # 勤怠変更申請承認関連のストロングパラメータとして使用
    def attendance_change_notice_params
      params.require(:user).permit(attendances: [:modification_request_status, :modification_change, :change_attendance_approval_date, :started_at, :finished_at, 
                                                :before_change_started_at, :before_change_finished_at, :modification_next_day])[:attendances]
    end

    # 残業申請関連のストロングパラメータとして使用
    def overwork_request_params
      params.require(:user).permit(attendances: [:worked_on, :scheduled_finished_at, :business_processing_content, :overwork_next_day, :request_user, 
                                                :overwork_request_status, :overwork_request_destination, :over_work_time])[:attendances]
    end

    # 残業申請承認関連のストロングパラメータとして使用
    def overwork_notice_params
      params.require(:user).permit(attendances: [:scheduled_finished_at, :business_processing_content, :overwork_change, :overwork_request_status, 
                                                :over_work_time, :overwork_next_day, :overwork_request_destination])[:attendances]
    end

    # 秒数の値を、時間単位に変更する（分母は分と秒の乗算）
    def overwork_time(time)
      format("%.2f", (time / 3600))
    end 
    
end