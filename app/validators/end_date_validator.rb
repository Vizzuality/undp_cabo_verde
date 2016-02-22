class EndDateValidator < ActiveModel::Validator
  def validate(record)
    if (record.start_date.present? && record.end_date.present?) && (record.end_date < record.start_date)
      record.errors.add(:end_date, 'End date must be after start date')
    end
  end
end
