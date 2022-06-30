class AddApplicationInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :scheduled_finished_at, :datetime
    add_column :attendances, :over_work_time, :datetime
    add_column :attendances, :overwork_next_day, :boolean, default: false
    add_column :attendances, :modification_next_day, :boolean, default: false
    add_column :attendances, :business_processing_content, :string
    add_column :attendances, :request_user, :integer
    add_column :attendances, :overwork_request_status, :string
    add_column :attendances, :modification_request_status, :string
    add_column :attendances, :one_month_request_status, :string
    add_column :attendances, :overwork_request_destination, :integer
    add_column :attendances, :modification_request_destination, :integer
    add_column :attendances, :one_month_request_destination, :integer
    add_column :attendances, :modification_change, :boolean, default: false
    add_column :attendances, :overwork_change, :boolean, default: false
    add_column :attendances, :one_month_change, :boolean, default: false
  end
end
