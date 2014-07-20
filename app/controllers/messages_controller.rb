class MessagesController < ApplicationController

  before_action :unread_counts, only: [:received, :sent, :archived]

  def received
    @message_threads = current_user.message_threads.joins(:messages).distinct.where("message_threads.status = ? AND messages.message_type = ?", GlobalConstants::MessageThreads::STATUS[:active], GlobalConstants::Messages::TYPE[:received])
  end

  def sent
    @message_threads = current_user.message_threads.joins(:messages).distinct.where("message_threads.status = ? AND messages.message_type = ?", GlobalConstants::MessageThreads::STATUS[:active], GlobalConstants::Messages::TYPE[:sent])
  end

  def archived
    @message_threads = current_user.message_threads.where("message_threads.status = ?", GlobalConstants::MessageThreads::STATUS[:archived])
  end

  def create
    message_thread = current_user.message_threads.find(params[:message_thread_id])
    begin
      ride = message_thread.ride
      sender = current_user
      receiver = message_thread.communicator
      message_body = params[:message][:body]
      ride.send_ride_offer_sms( sender, receiver, message_body )
      ride.send_private_message(sender, receiver, message_body)
      redirect_to message_thread_path(message_thread.id)
    rescue Exception => e
      puts "=== message create ==="
      puts e
      redirect_to message_thread_path(message_thread.id), danger: "Unable to pass your message."
    end  
  end

  private
  def unread_counts
    @unread_sent_message_thread     =  current_user.message_threads.joins(:messages).distinct.where("message_threads.status = ? AND message_threads.unread = ? AND messages.message_type = ?", GlobalConstants::MessageThreads::STATUS[:active], true, GlobalConstants::Messages::TYPE[:sent]).count
    @unread_received_message_thread =  current_user.message_threads.joins(:messages).distinct.where("message_threads.status = ? AND message_threads.unread = ? AND messages.message_type = ?", GlobalConstants::MessageThreads::STATUS[:active], true, GlobalConstants::Messages::TYPE[:received]).count
    @unread_sent_message_thread = nil if @unread_sent_message_thread == 0
    @unread_received_message_thread = nil if @unread_received_message_thread == 0
  end

end
