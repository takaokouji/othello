# == Schema Information
# Schema version: 20100111055400
#
# Table name: players
#
#  id         :integer       not null, primary key
#  name       :string(255)
#  ai         :text
#  created_at :datetime
#  updated_at :datetime
#

class Player < ActiveRecord::Base
end
