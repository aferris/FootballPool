require "digest/sha1"

class User < ActiveRecord::Base
  has_one :weekly_user_point
  has_one :tiebreaker

  attr_accessor :password
  attr_accessible :login, :password, :email_address, :first_name, :last_name
  
  validates_uniqueness_of :login
  validates_presence_of   :login, :password, :first_name
  validates_format_of :email_address, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i 
  
  before_destroy :dont_destroy_aferris
  
  def before_create
    self.hashed_password = User.hash_password(self.password)
  end
  
  def before_update
    self.hashed_password = User.hash_password(self.password)
  end

  def after_create
    @password = nil
  end
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end
  
  def self.login(login, password)
    hashed_password = hash_password(password || "")
    find(:first, :conditions => ["login = ? and hashed_password = ?",
                                  login, hashed_password])
  end
  
  def try_to_login
    User.login(self.login, self.password)
  end
  
  def dont_destroy_aferris
    raise "Can't destroy aferris" if self.login == 'aferris'
  end
end
