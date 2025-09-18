defmodule LobserverTest do
  use ExUnit.Case
  doctest Lobserver

  test "greets the world" do
    assert Lobserver.hello() == :world
  end
end
