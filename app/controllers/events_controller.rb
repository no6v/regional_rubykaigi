# -*- coding: utf-8 -*-
class EventsController < ApplicationController
  before_filter :fetch_event, :except => [:index]
  before_filter :check_published, :except => [:index]
  before_filter :check_registration_enabled, :except => [:index, :show]

  verify :method => :post, :only => :register, :redirect_to => {:action => "index"}
  def index
    @upcomings = Event.upcomings
    @archives = Event.archives
  end

  def show
    return if render_original_template
  end

  def registration
    @attendee = Attendee.new
  end

  def register
    @attendee = Attendee.new(params[:attendee])
    @attendee.remote_ip = request.remote_ip
    @attendee.event = @event
    if @attendee.save
      if @event.notify_email_enabled?
        Registration.deliver_message(@attendee)
      end
      redirect_to :action => 'done', :name => @event.name
    else
      render :action => 'registration'
    end
  end

  private
  def fetch_event
    case params[:name]
    when "tokyo02"
      redirect_to event_path(:action => 'show', :name => 'tokyu01')
      return
    when "tokyo04"
      redirect_to event_path(:action => 'show', :name => 'tokyu02')
      return
    when "tokyo06", "oedorubykaigi01"
      redirect_to event_path(:action => 'show', :name => 'oedo01')
      return
    when "tokyo07"
      redirect_to event_path(:action => 'show', :name => 'tokyu03')
      return
    end

    @event = Event.find_by_name(params[:name])
    unless @event
      render :file => "public/404.html", :status => 404
      return
    end
    @page_title = @event.title
  end

  def check_registration_enabled
    unless @event.registration_enabled?
      redirect_to :action => 'show', :name => @event.name
    end
  end

  def check_published
    return true if logged_in_as_admin?
    unless @event.published?
      # FIXME もうちょっとユーザフレンドリーに
      redirect_to :action => 'index'
    end
  end

  def render_original_template
    begin
      render @event.name, :layout => false
    rescue ActionView::MissingTemplate
      return false
    end
  end
end
