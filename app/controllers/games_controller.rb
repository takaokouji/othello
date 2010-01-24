# -*- coding: utf-8 -*-
class GamesController < ApplicationController
  before_filter :login_required

  # GET /games/1
  # GET /games/1.xml
  def show
    add_breadcrumb("ゲーム", "")
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game }
    end
  end

  # GET /games/new
  # GET /games/new.xml
  def new
    add_breadcrumb("対戦相手を選ぶ", "")
    if params[:player_id]
      attrs = {}
      attrs[:owner] = current_user.players.find(params[:player_id])
      if params[:first_or_second] == 1
        attrs[:second_player] = attrs[:owner]
      else
        attrs[:first_player] = attrs[:owner]
      end
      case params[:board_size]
      when "0"
        size = 8
      when "1"
        size = 16
      when "2"
        size = 32
      when "3"
        size = 64
      else
        size = 64
      end
      attrs[:board_width] = size
      attrs[:board_height] = size
      case params[:time]
      when "0"
        time = 1
      when "1"
        time = 3
      when "2"
        time = 5
      when "3"
        time = 10
      else
        time = 10
      end
      attrs[:time] = time
      session[:game_new_attr] = attrs
    else
      attrs = session[:game_new_attr]
    end
    
    @game = Game.new(attrs)

    @users = User.paginate(:page => params[:page], :order => "name")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game }
    end
  end

  # POST /games
  # POST /games.xml
  def create
    session[:game_new_attr] = nil
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        flash[:notice] = 'Game was successfully created.'
        format.html { redirect_to(@game) }
        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # ゲームを開始する。
  def start
    @game = Game.find(params[:id])
    @game.start
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @game }
    end
  end

  # 次の一手を設定する。
  def next_piece
    @game = Game.find(params[:id])
    @game.next_piece

    respond_to do |format|
      if @game.timeup?
        format.html { redirect_to(:action => "stop", :id => @game) }
      else
        format.html
      end
    end
  end

  # ゲームを停止する。
  def stop
    @game = Game.find(params[:id])
    @game.stop

    respond_to do |format|
      format.html
    end
  end
end
