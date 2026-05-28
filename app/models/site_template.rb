# frozen_string_literal: true

class SiteTemplate < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true
  validates :body, presence: true
end
