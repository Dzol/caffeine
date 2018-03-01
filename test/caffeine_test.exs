defmodule CaffeineTest do
  use ExUnit.Case
  doctest Caffeine

  test "API presence under Stream module" do
    assert Caffeine.Stream.__info__(:functions) == [take: 2]
  end
end
