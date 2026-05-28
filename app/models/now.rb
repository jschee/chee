# frozen_string_literal: true

class Now < ActiveRecord::Base
  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :raw_body, presence: true
  validates :html_body, presence: true
end
