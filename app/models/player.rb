# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20100129033650
#
# Table name: players
#
#  id         :integer       not null, primary key
#  name       :string(255)
#  ai         :text
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#  enable     :boolean
#

class Player < ActiveRecord::Base
  # デフォルトのAI
  DEFAULT_AI = "def solve(context)\n  context.set_next_piece(*context.candidates.first)\nend"

  belongs_to :user
  has_many :games, :foreign_key => "owner_id"
  
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
    return games.select { |g| g.winner == self }.length
  end
  
  # 引き分けの回数を取得する。
  def num_draws
    return games.select { |g| g.winner == nil }.length
  end

  # 負けた回数を取得する。
  def num_loses
    return games.length - num_wins - num_draws
  end
end
