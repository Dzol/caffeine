defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties

  property "sentinel?/1 true if sentinel/0 false if construct/2" do
    assert Caffeine.Stream.sentinel?(Caffeine.Stream.sentinel()) == true

    check all e <- term() do
      f = fn ->
        Caffeine.Stream.sentinel()
      end

      x = Caffeine.Stream.construct(e, f)
      assert Caffeine.Stream.sentinel?(x) == false
    end

    check all t <- term(), t != Caffeine.Stream.sentinel() do
      assert_raise FunctionClauseError, fn ->
        Caffeine.Stream.sentinel?(t)
      end
    end
  end

  property "head/1 is argument #1 of construct/2" do
    ## given
    check all e <- term(),
              l <- list_of(term()) do
      f = fn ->
        CaffeineTest.Ancillary.List.stream(l)
      end

      ## when
      s = Caffeine.Stream.construct(e, f)
      ## then
      assert Caffeine.Stream.head(s) == e
    end
  end

  property "tail/1 is argument #2 of construct/2" do
    ## given
    check all e <- term(),
              l <- list_of(term()) do
      f = fn ->
        CaffeineTest.Ancillary.List.stream(l)
      end

      ## when
      s = Caffeine.Stream.construct(e, f)
      ## then
      assert Caffeine.Stream.tail(s) == f.()
    end
  end

  property "map/2 preserves order" do
    ## given
    check all l <- list_of(term()) do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t = Caffeine.Stream.map(s, &identity/1)
      ## then
      assert Caffeine.Stream.take(t, length(l)) === l
    end
  end

  property "map/2 applies function" do
    ## given
    check all l <- list_of(integer()) do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t = Caffeine.Stream.map(s, &double/1)
      ## then
      assert Caffeine.Stream.take(t, length(l)) === Enum.map(l, &double/1)
    end
  end

  defp identity(x) do
    x
  end

  defp double(x) do
    2 * x
  end
end
