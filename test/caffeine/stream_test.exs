defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Caffeine.Stream

  test "pull elements out" do
    ## given
    defmodule Constant.Pi do
      def stream do
        [value() | rest()]
      end

      defp rest do
        fn -> stream() end
      end

      def value do
        3.14159265359
      end
    end

    ## when
    s = Constant.Pi.stream()
    l = Caffeine.Stream.take(s, 5)
    ## then
    assert length(l) === 5
  end

  test "map/2 changes stream elements" do
    ## given
    defmodule Constant.E do
      def stream do
        [value() | rest()]
      end

      defp rest do
        fn -> stream() end
      end

      def value do
        2.71828
      end
    end

    double = fn x ->
      2 * x
    end

    ## when
    s = Constant.E.stream()
    d = Caffeine.Stream.map(s, double)
    l = Caffeine.Stream.take(d, 5)
    ## then
    ## Curious behaviour for Enum.all? when []
    assert Enum.all?(l, fn x -> 2 * Constant.E.value() === x end)
  end

  test "reach the end" do
    ## given
    defmodule Constant.Bound.Pi do
      def stream(0) do
        []
      end

      def stream(x) when is_integer(x) and x > 0 do
        [value() | rest(x)]
      end

      defp rest(x) do
        fn -> stream(x - 1) end
      end

      def value do
        3.14159265359
      end
    end

    ## when
    s = Constant.Bound.Pi.stream(3)
    l = Caffeine.Stream.take(s, 5)
    ## then
    assert length(l) === 3
  end

  defmodule Constant.Bound do
    def stream(limit: 0, value: _) do
      []
    end

    def stream(limit: b, value: v) do
      [v | rest(b, v)]
    end

    defp rest(b, v) do
      fn -> stream(limit: decrement(b), value: v) end
    end

    defp decrement(x) do
      x - 1
    end
  end

  property "take/2 no more than we ask" do
    check all t <- term(),
              b <- positive_integer(),
              i <- positive_integer() do
      ## when
      s = Constant.Bound.stream(limit: b, value: t)
      l = Caffeine.Stream.take(s, i)
      ## then
      assert length(l) <= i
    end
  end

  property "take/2 values that we ask" do
    check all t <- term(),
              b <- positive_integer(),
              i <- positive_integer() do
      ## when
      s = Constant.Bound.stream(limit: b, value: t)
      l = Caffeine.Stream.take(s, i)
      ## then
      assert Enum.all?(l, value?(t))
    end
  end

  defp value?(x) do
    fn v ->
      v == x
    end
  end
end
