# -*- coding: utf-8 -*-
# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default(root_path)
      flash[:notice] = "ログインしました"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :template => "welcome/index"
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "ログアウトしました。"
    redirect_back_or_default(root_path)
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "ログインに失敗しました"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end