defmodule SpyRadio.SecureChannel do
  defstruct connection: nil, channels: %{}
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> __MODULE__.new() end, name: __MODULE__)
  end

  def new do
    {:ok, conn} = AMQP.Connection.open("amqp://guest:guest@localhost")
    struct!(__MODULE__, connection: conn)
  end

  def connect(pid) do
    Agent.get_and_update(__MODULE__, &setup(pid, &1))
  end

  def setup(pid, %__MODULE__{connection: connection, channels: channels} = struct) do
    if channels[pid] do
      {{:ok, channels[pid]}, struct}
    else
      {:ok, channel} = AMQP.Channel.open(connection)
      {{:ok, channel}, struct.channels[pid] |> put_in(channel)}
    end
  end

  def get_state do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
