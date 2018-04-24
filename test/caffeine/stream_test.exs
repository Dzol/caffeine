defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Caffeine.Stream

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

  property "all elements of filter/2 prescribe to the predicate" do
    ## given
    check all l <- list_of(integer()) do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t = Caffeine.Stream.filter(s, &even?/1)
      ## then
      assert Enum.all?(Caffeine.Stream.take(t, length(l)), &even?/1)
    end
  end

  property "filter/2 cardinality is less than or equal to input" do
    ## given
    check all l <- list_of(integer()) do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t = Caffeine.Stream.filter(s, &even?/1)
      ## then
      assert length(listify(t)) <= length(l)
    end
  end

  property "skip/2 cardinality is less than or equal to input" do
    ## given
    check all l <- list_of(integer()),
              i <- natural() do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t = Caffeine.Stream.skip(s, i)
      ## then
      assert length(listify(t)) <= length(l)
    end
  end

  property "after skip/2 the same elements reside in the rest of the stream" do
    ## given
    check all l <- list_of(integer()),
              i <- natural() do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t1 = Caffeine.Stream.skip(s, i)
      t2 = Enum.drop(l, i)
      ## then
      assert listify(t1) === t2
    end
  end

  defp identity(x) do
    x
  end

  defp double(x) do
    2 * x
  end

  defp even?(x) do
    rem(x, 2) === 0
  end

  defp listify(s) do
    import Caffeine.Stream

    cond do
      sentinel?(s) ->
        []

      construct?(s) ->
        [head(s) | listify(tail(s))]
    end
  end

  defp natural do
    one_of([constant(0), positive_integer()])
  end
end
