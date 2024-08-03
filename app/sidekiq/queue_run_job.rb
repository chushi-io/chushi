class QueueRunJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
    conn = Bunny.new
    conn.start

    ch = conn.create_channel
    ch.confirm_select

    q  = ch.queue("test1")

    q.publish("Hello, everybody!")
  end
end
