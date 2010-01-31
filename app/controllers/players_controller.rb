# -*- coding: utf-8 -*-
class PlayersController < ApplicationController
  before_filter :login_required
  before_filter :find_player
  
  in_place_edit_for :player, :name

  # GET /players/1
  # GET /players/1.xml
  def show
    add_breadcrumb(@player.name, "")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @player }
    end
  end

  # GET /players/1/edit
  def edit
    if current_user.guest?
      raise "ゲストアカウントはプレイヤーの情報を編集できません"
    end
    add_breadcrumb(@player.name, "player_path(@player)")
    add_breadcrumb("編集", "")
  end

  # PUT /players/1
  # PUT /players/1.xml
  def update
    if current_user.guest?
      raise "ゲストアカウントはプレイヤーの情報を編集できません"
    end
    respond_to do |format|
      if @player.update_attributes(params[:player])
        flash[:notice] = 'Player was successfully updated.'
        format.html { redirect_to(@player) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @player.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private
  
  def find_player
    @player = current_user.players.find(params[:id])
    return true
  end
end
