module ApplicationHelper
  
  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?
      base_titile
    else
      page_name + " | " + base_title
    end
  end

  # 秒数の値を、時間単位に変更する（分母は分と秒の乗算）
  def overwork_time(time)
    format("%.2f", (time / 3600))
  end  
  
end