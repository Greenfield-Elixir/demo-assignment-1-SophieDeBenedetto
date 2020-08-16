defmodule SpyRadio.HeadquartersTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias SpyRadio.{Headquarters, SecureChannel}

  @queue "my_queue"
  @exchange "enigma"

  setup do
    {:ok, channel} = SecureChannel.connect(self())
    Headquarters.wait_for_message(channel, @queue, @exchange)
    %{channel: channel}
  end

  test "wait_for_messages/3 declares a queue", %{channel: channel} do
    status = AMQP.Queue.status(channel, @queue)

    {:ok,
     %{
       consumer_count: _consumer_count,
       message_count: _message_count,
       queue: @queue
     }} = status
  end

  test "wait_for_messages/3 declares a fanout exchange", %{channel: channel} do
    response = AMQP.Exchange.declare(channel, @exchange, :fanout, passive: true)
    assert response == :ok
  end

  test "wait_for_messages/3 subscribes to the queue", %{channel: channel} do
    {:ok,
     %{
       consumer_count: consumer_count,
       message_count: _message_count,
       queue: @queue
     }} = AMQP.Queue.status(channel, @queue)

    assert consumer_count > 0
  end

  test "handle_message/2 puts the message to the terminal" do
    assert capture_io(fn -> Headquarters.handle_message("secret message", %{}) end) ==
             "Got super secret message: secret message\n"
  end

  test "it handles messages published to the queue so that a published message is removed from the queue and processed", %{channel: channel} do
    AMQP.Basic.publish(channel, @exchange, "", "secret message")
    {:ok,
     %{
       consumer_count: _consumer_count,
       message_count: message_count,
       queue: @queue
     }} = AMQP.Queue.status(channel, @queue)

    assert message_count == 0
  end
end
