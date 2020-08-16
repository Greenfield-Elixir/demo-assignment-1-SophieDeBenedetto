defmodule SpyRadio.Headquarters do
  def wait_for_message(channel, queue_name, exchange_name) do
    AMQP.Queue.declare(channel, queue_name)
    AMQP.Exchange.declare(channel, exchange_name, :fanout)
    AMQP.Queue.bind(channel, queue_name, exchange_name)

    AMQP.Queue.subscribe(channel, queue_name, &handle_message/2)
  end

  def handle_message(message, _metadata) do
    IO.puts("Got super secret message: #{message}")
  end
end
