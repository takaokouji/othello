# -*- coding: utf-8 -*-
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
  # デフォルトのAI
  DEFAULT_AI = "def solve(context)\n  context.set_next_piece(*context.candidates.first)\nend"

  belongs_to :user
  
  # aiカラムの文字列を元に、このインスタンスにだけsolveメソッドを定義する。
  def load_ai
    instance_eval(ai, __FILE__, __LINE__)
  end
  
  # aiの行数を数える。
  def num_ai_lines
    return ai.to_a.length
  end

  # 勝った回数を取得する。
  def num_wins
    return 0
  end
  
  # 負けた回数を取得する。
  def num_loses
    return 0
  end
end
