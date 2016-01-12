class PrototypeController < ApplicationController

  layout 'prototype'

  def index
    @domains = Category.where(type: ['SocioCulturalDomain', 'OtherDomain'])
      .order(:name)
  end
end
