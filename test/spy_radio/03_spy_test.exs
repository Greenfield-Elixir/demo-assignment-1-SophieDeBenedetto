defmodule SpyRadio.SpyTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias SpyRadio.{Spy, SecureChannel}

  setup do
    {:ok, channel} = SecureChannel.connect(self())
    %{channel: channel}
  end

  test "send_secret_message/2 publishes the message to the 'enigma' exchange", %{channel: channel} do
    :ok = Spy.send_secret_message(channel, "secret message, don't tell anyone.")
  end
end
