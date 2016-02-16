class PrototypeController < ApplicationController
  layout 'prototype'

  def index
    @socio_cultural_domains = Category.where(type: ['SocioCulturalDomain']).order(:name)
    @other_domains = Category.where(type: ['OtherDomain']).order(:name)
    @start_date = min_start_date
    @end_date   = max_end_date
    gon.min_date = @start_date
    gon.max_date = @end_date
  end

  private

    def min_start_date
      [
        Localization.minimum(:start_date) || Date.today,
        Act.minimum(:start_date) || Date.today
      ].min
    end

    def max_end_date
      [
        Localization.maximum(:end_date) || Date.today,
        Act.maximum(:end_date) || Date.today
      ].max
    end
end
