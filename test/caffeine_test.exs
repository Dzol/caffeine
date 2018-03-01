defmodule CaffeineTest do
  use ExUnit.Case
  doctest Caffeine

  test "API presence under Stream module" do
    assert Caffeine.Stream.__info__(:functions) == [map: 2, take: 2]
  end
end
