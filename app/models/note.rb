class Note < ApplicationRecord
  belongs_to :user
  validates :video_url, presence: true
  acts_as_taggable_on :tags
end
