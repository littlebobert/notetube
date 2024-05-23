class Note < ApplicationRecord
  belongs_to :user
  validates :video_url, presence: true

  # after_save :method

  # def method
  #   # self.transcript = TranscriptGenerator.beautify_transcript(self.transcript)
  #   # self.save
  # end
end
