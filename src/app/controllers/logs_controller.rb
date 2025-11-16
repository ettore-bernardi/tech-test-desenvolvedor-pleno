# frozen_string_literal: true

class LogsController < ApplicationController
  def index
    @logs = EmailLog.order(created_at: :desc).limit(200)
  end

  def show
    @log = EmailLog.find(params[:id])
  end
end
