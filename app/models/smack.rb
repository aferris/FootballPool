class Smack < ActiveRecord::Base
  def self.random_message
    myRand = ActiveSupport::SecureRandom.random_number(12)
    myRand += 1
    
    Smack.find(myRand).message
  end
end
