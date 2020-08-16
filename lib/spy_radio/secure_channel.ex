defmodule SpyRadio.SecureChannel do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> __MODULE__.new() end, name: __MODULE__)
  end

  def new do
  end

  def get_state do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
