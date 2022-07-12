module UsersHelper
  
  # 勤怠基本情報を指定のフォーマットで返す。
  def format_basic_info(time)
    if time.nil?
      nil
    else
      format("%.2f", (((time.hour * 60) + time.min) / 60.0))
    end
  end

  # 秒数の値を、時間単位に変更する（分母は分と秒の乗算）
  def overwork_time(time)
    format("%.2f", (time / 3600))
  end
  
end
