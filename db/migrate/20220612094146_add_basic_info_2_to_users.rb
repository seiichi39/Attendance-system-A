class AddBasicInfo2ToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :integer
    add_column :users, :uid, :string
    add_column :users, :superior, :boolean, default: false
    add_column :users, :basic_work_time, :datetime
    add_column :users, :designed_work_start_time, :datetime
    add_column :users, :designed_work_end_time, :datetime
  end
end
