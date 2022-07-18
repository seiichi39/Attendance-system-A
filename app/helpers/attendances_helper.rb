module AttendancesHelper
  
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

  # 秒数の値を、時間単位に変更する（分母は分と秒の乗算）
  def overwork_time(time)
    format("%.2f", (time / 3600))
  end
  
end
