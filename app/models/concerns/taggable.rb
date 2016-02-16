module Taggable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable
  end

  def tags_count
    tag_counts_on(:tags).size
  end

  def tag_list_with_limit(limit = nil)
    return tags if limit.blank?

    tags.sort{|a,b| b.taggings_count <=> a.taggings_count}[0, limit]
  end

  def tags_count_out_of_limit(limit = nil)
    return 0 unless limit

    count = tags.size - limit
    count < 0 ? 0 : count
  end
end
