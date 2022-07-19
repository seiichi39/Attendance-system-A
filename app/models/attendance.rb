class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_is_invalid_without_a_finished_at, on: :validate_one_month
  validate :after_change_finished_at_is_invalid_without_a_after_change_started_at
  validate :after_change_started_at_is_invalid_without_a_after_change_finished_at
  validate :invalid_without_a_after_change_time
  validate :started_at_than_finished_at_fast_if_invalid
  validate :after_change_started_at_than_after_change_finished_at_fast_if_invalid
  validate :after_time_invalid_without_a_modification_request_destination
  validate :next_day_and_note_invalid_without_a_modification_request_destination
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_is_invalid_without_a_finished_at
    errors.add(:finished_at, "が必要です") if finished_at.blank? && started_at.present?
  end

  # 変更する退社時間のみ入力されている場合、申請を無効とする。
  def after_change_finished_at_is_invalid_without_a_after_change_started_at
    errors.add(:after_change_started_at, "が必要です") if after_change_started_at.blank? && after_change_finished_at.present? 
  end

  # 変更する出社時間のみ入力されている場合、申請を無効とする。
  def after_change_started_at_is_invalid_without_a_after_change_finished_at
    errors.add(:after_change_finished_at, "が必要です") if after_change_finished_at.blank? && after_change_started_at.present?
  end
  
  # 変更する出社時間・退社時間が未入力でかつ申請先が入力されている場合、申請を無効とする。
  # ※errorsに対しての引数は複数に対してできるか分からないため、after_change_started_atを対象とした。
  def invalid_without_a_after_change_time
    errors.add(:after_change_started_at, "が必要です") if after_change_finished_at.blank? && after_change_started_at.blank? && modification_request_destination.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end

  # 変更する退社時間が、変更する出社時間よりも前の場合、申請を無効とする。
  def after_change_started_at_than_after_change_finished_at_fast_if_invalid
    if after_change_started_at.present? && after_change_finished_at.present? && (modification_next_day == false)
      errors.add(:after_change_started_at, "より早い退勤時間は無効です") if after_change_started_at > after_change_finished_at
    end
  end

  # 変更する出社時間・退社時間が入力してあるにも関わらず、上長が選択されていない場合、申請を無効とする。
  def after_time_invalid_without_a_modification_request_destination
    if after_change_started_at.present? && after_change_finished_at.present?
      errors.add(:modification_request_destination, "が必要です") if modification_request_destination.blank?
    end
  end

  # 翌日チェックまたは備考が入力してあっても、上長が選択されていない場合、申請を無効とする。
  def next_day_and_note_invalid_without_a_modification_request_destination
    if modification_next_day.present? || note.present?
      errors.add(:modification_next_day, "が必要です") if modification_request_destination.blank?
    end
  end  

  def started_at_time
    if started_at.present?
      started_at.strftime("%H：%M")
    end
  end

  def finished_at_time
    if finished_at.present?
      finished_at.strftime("%H：%M")
    end
  end  
  
end
