require "digest/sha1"

class User < ActiveRecord::Base
  has_many :weekly_user_points
  has_one :total_user_point
  has_many :tiebreakers
  has_many :picks

  attr_accessor :password
  attr_accessible :login, :password, :email_address, :first_name, :last_name
  
  validates :login, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :first_name, :presence => true
  validates :email_address, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i  }
  
  before_destroy :dont_destroy_aferris
  
  before_create { self.hashed_password = hash_password(self.password) } 
  before_update { self.hashed_password = hash_password(self.password) }
  after_create  { @password = nil }
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end
  
  def self.login(login, password)
    hashed_password = hash_password(password || "")
    where(:login => login, :hashed_password => hashed_password).first
  end
  
  def try_to_login
    User.login(self.login, self.password)
  end
  
  private
  
  def dont_destroy_aferris
    raise "Can't destroy aferris" if self.login == 'aferris'
  end
end
