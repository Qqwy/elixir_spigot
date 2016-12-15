defmodule SpigotTest do
  use ExUnit.Case
  doctest Spigot

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "The Spigot.convert/2 function works just like explained in the paper." do
    assert Spigot.convert({3, 7},  [1,0,0,2,2,1,0,1,1,2]) |> Enum.take(100) === [2, 4, 0, 1, 1]
  end

end
