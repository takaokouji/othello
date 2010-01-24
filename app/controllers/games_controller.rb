# -*- coding: utf-8 -*-
class GamesController < ApplicationController
  before_filter :login_required

  # GET /games/new
  # GET /games/new.xml
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game }
    end
  end

  # POST /games
  # POST /games.xml
  def create
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
      format.html
      format.xml  { render :xml => @game }
    end
  end

  # ゲームを停止する。
  def stop
    @game = Game.find(params[:id])
    @game.stop

    respond_to do |format|
      format.html
      format.xml  { render :xml => @game }
    end
  end
end
