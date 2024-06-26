class Note < ApplicationRecord
  belongs_to :user
  validates :video_url, presence: true
  validates :video_id, presence: true, uniqueness: true
  acts_as_taggable_on :tags
end
