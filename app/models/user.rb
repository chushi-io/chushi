class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :organization_memberships
  has_many :organizations, through: :organization_memberships
  has_many :access_tokens, as: :token_authable

  has_many :team_memberships
  has_many :teams, through: :team_memberships
  before_create -> { generate_id("user") }
end
