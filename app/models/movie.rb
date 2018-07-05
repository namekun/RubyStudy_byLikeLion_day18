class Movie < ApplicationRecord
    mount_uploader :image_path, ImageUploader
    has_many :likes
    has_many :users, through: :likes #likes를 통해서 많은 user를!
    has_many :comments
end
