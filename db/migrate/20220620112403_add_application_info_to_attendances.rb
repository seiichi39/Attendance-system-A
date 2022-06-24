class AddApplicationInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :scheduled_finished_at, :datetime
    add_column :attendances, :over_work_time, :datetime
    add_column :attendances, :next_day, :boolean, default: false
    add_column :attendances, :business_processing_content, :string
    add_column :attendances, :application_status, :integer
    add_column :attendances, :application_destination, :string
  end
end
