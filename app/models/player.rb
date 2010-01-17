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
  # aiカラムの文字列を元に、このインスタンスにだけsolveメソッドを定義する。
  def load_ai
    instance_eval(ai, __FILE__, __LINE__)
  end
end
