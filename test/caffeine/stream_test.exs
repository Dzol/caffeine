defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Caffeine.Stream

  test "expression inside construct/2 builds good stream" do
    x = CaffeineTest.Ancillary.Natural.lazy()
    assert Caffeine.Stream.head(x) === 0
  end

  test "expression outside construct/2 builds bad stream" do
    t = Task.async(&CaffeineTest.Ancillary.Natural.eager/0)
    assert Task.shutdown(t, 5000) == nil
  end

  property "sentinel?/1 true if sentinel/0 false if construct/2" do
    assert Caffeine.Stream.sentinel?(Caffeine.Stream.sentinel()) == true

    check all e <- term() do
      x = Caffeine.Stream.construct(e, Caffeine.Stream.sentinel())
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
      ## when
      s = Caffeine.Stream.construct(e, CaffeineTest.Ancillary.List.stream(l))
      ## then
      assert Caffeine.Stream.head(s) == e
    end
  end

  property "tail/1 is argument #2 of construct/2" do
    ## given
    check all e <- term(),
              l <- list_of(term()) do
      ## when
      s = Caffeine.Stream.construct(e, CaffeineTest.Ancillary.List.stream(l))
      ## then
      assert Caffeine.Stream.tail(s) == CaffeineTest.Ancillary.List.stream(l)
    end
  end

  property "map/2 w/ the identity function produces a like stream" do
    ## given
    check all l <- list_of(term()) do
      s = CaffeineTest.Ancillary.List.stream(l)
      ## when
      t = Caffeine.Stream.map(s, &identity/1)
      ## then
      assert Caffeine.Stream.take(t, length(l)) === l
    end
  end

  defp identity(x) do
    x
  end
end
