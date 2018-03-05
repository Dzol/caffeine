defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Caffeine.Stream

  defmodule Constant.Bound do
    @moduledoc """
    A stream of constant values that stops once a limit is reached
    """
    require Caffeine.Stream

    def stream(limit: 0, value: _) do
      Caffeine.Stream.sentinel()
    end

    def stream(limit: l, value: v) when is_integer(l) and l > 0 do
      Caffeine.Stream.construct(v, stream(limit: decrement(l), value: v))
    end

    defp decrement(x) do
      x - 1
    end
  end

  test "pull elements out" do
    ## given
    s = Constant.Bound.stream(limit: 5, value: pi())
    ## when
    l = Caffeine.Stream.take(s, 5)
    ## then
    assert length(l) === 5
  end

  test "map/2 changes stream elements" do
    ## given
    s = Constant.Bound.stream(limit: 5, value: e())
    ## when
    d = Caffeine.Stream.map(s, &double/1)
    l = Caffeine.Stream.take(d, 5)
    ## then
    assert Enum.all?(l, fn x -> 2 * e() === x end)
  end

  test "reach the end" do
    ## given
    s = Constant.Bound.stream(limit: 3, value: pi())
    ## when
    l = Caffeine.Stream.take(s, 5)
    ## then
    assert length(l) === 3
  end

  property "take/2 no more than we ask" do
    check all t <- term(),
              l <- positive_integer(),
              i <- positive_integer() do
      ## given
      s = Constant.Bound.stream(limit: l, value: t)
      ## when
      l = Caffeine.Stream.take(s, i)
      ## then
      assert length(l) <= i
    end
  end

  property "take/2 values that we ask" do
    check all t <- term(),
              l <- positive_integer(),
              i <- positive_integer() do
      ## given
      s = Constant.Bound.stream(limit: l, value: t)
      ## when
      l = Caffeine.Stream.take(s, i)
      ## then
      assert Enum.all?(l, value?(t))
    end
  end

  property "head/1" do
    ## given
    check all t <- term() do
      ## when
      s = Caffeine.Stream.construct(t, Caffeine.Stream.sentinel())
      ## then
      assert Caffeine.Stream.head(s) === t
    end
  end

  property "tail/1" do
    ## given
    check all h <- term(),
              t <- term() do
      ## when
      s = Caffeine.Stream.construct(h, t)
      ## then
      assert Caffeine.Stream.tail(s) === t
    end
  end

  defp pi do
    3.14159265359
  end

  defp e do
    2.71828
  end

  defp double(x) do
    2 * x
  end

  defp value?(x) do
    fn v ->
      v == x
    end
  end
end
