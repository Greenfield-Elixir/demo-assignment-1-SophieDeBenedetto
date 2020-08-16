defmodule SpyRadio.Spy do
  @exchange_name "enigma"
  @routing_key ""
  def send_secret_message(channel, message) do
    AMQP.Exchange.declare(channel, @exchange_name, :fanout)
    AMQP.Basic.publish(channel, @exchange_name, @routing_key, message)
  end
end
