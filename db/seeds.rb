# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'google/apis/youtube_v3'
require_relative '../app/controllers/notes_controller'

Note.destroy_all
User.destroy_all

user = User.create!(email: "test@gmail.com", password: "password")

puts "created #{User.count} users and #{Note.count} notes"
