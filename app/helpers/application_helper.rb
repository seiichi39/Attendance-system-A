module ApplicationHelper
  
  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?
      base_titile
    else
      page_name + " | " + base_title
    end
  end
  
end