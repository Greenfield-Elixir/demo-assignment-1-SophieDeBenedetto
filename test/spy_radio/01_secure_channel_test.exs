defmodule SpyRadio.SecureChannelTest do
  use ExUnit.Case
  alias SpyRadio.SecureChannel

  test "it starts when the application starts" do
    secure_channel_agent_pid = Process.whereis(SecureChannel)
    assert secure_channel_agent_pid != nil
  end

  test "start_link/1 opens a RabbitMQ connection and stores it in state" do
    secure_channel_agent_pid = Process.whereis(SecureChannel)
    state = SecureChannel.get_state()
    %{connection: %AMQP.Connection{}} = state
  end

  test "connect/1 opens a RabbitMQ channel over the connection stored in state updates state" do
    pid = self()
    SecureChannel.connect(pid)
    state = SecureChannel.get_state()

    %{
      channels: %{
        ^pid => %AMQP.Channel{}
      }
    } = state
  end

  test "connect/1 returns the newly opened channel" do
    {:ok, %AMQP.Channel{}} = SecureChannel.connect(self())
  end

  test "connect/1 returns a different channel per process" do
    {:ok, channel1} = SecureChannel.connect(self())
    {:ok, channel2} = SecureChannel.connect(forever_pid())
    assert channel1 != channel2
  end

  test "connect/1 does not open multiple channels for the same process" do
    {:ok, channel1} = SecureChannel.connect(self())
    {:ok, channel2} = SecureChannel.connect(self())
    assert channel1 == channel2
  end

  def forever_pid do
    spawn(fn ->
      receive do
        :never_die -> :ok_fine
      end
    end)
  end
end
