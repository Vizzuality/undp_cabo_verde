require 'rails_helper'

RSpec.describe Localization, type: :model do
  before :each do
    @localization = create(:localization, name: 'First Localization', web_url: 'test-web.org')
  end

  let!(:location_params_invalid_end_date) do
    { lat: 123, long: 123, start_date: Time.zone.now, end_date: Time.zone.now.change(month: '01') }
  end

  it 'Create Localization' do
    expect(@localization.name).to eq('First Localization')
    expect(@localization.lat).not_to be_nil
    expect(@localization.long).not_to be_nil
    expect(@localization.country).not_to be_nil
    expect(@localization.city).not_to be_nil
    expect(@localization.web_url).to eq('http://test-web.org')
  end

  it 'end_date validation' do
    @localization = Localization.create(location_params_invalid_end_date)

    @localization.valid?
    expect {@localization.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: End date End date must be after start date")
  end
end
