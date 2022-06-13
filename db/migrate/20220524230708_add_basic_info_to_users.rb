class AddBasicInfoToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :designed_work_start_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    add_column :users, :designed_work_end_time, :datetime, default: Time.current.change(hour: 7, min: 30, sec: 0)
  end
end
