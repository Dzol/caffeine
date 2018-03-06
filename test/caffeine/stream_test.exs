defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Caffeine.Stream

  defmodule Natural do
    require Caffeine.Stream

    def lazy do
      lazy(0)
    end

    def eager do
      eager(0)
    end

    defp lazy(n) do
      Caffeine.Stream.construct(n, lazy(increment(n)))
    end

    defp eager(n) do
      i = eager(increment(n))
      Caffeine.Stream.construct(n, i)
    end

    defp increment(n) do
      n + 1
    end
  end

  test "expression inside construct/2 builds good stream" do
    x = Natural.lazy()
    assert Caffeine.Stream.head(x) === 0
  end

  test "expression outside construct/2 builds bad stream" do
    t = Task.async(&Natural.eager/0)
    assert Task.shutdown(t, 5000) == nil
  end

  defmodule List do
    require Caffeine.Stream

    def stream([]) do
      Caffeine.Stream.sentinel()
    end

    def stream(l) when is_list(l) do
      Caffeine.Stream.construct(hd(l), stream(tl(l)))
    end
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
      s = Caffeine.Stream.construct(e, List.stream(l))
      ## then
      assert Caffeine.Stream.head(s) == e
    end
  end

  property "tail/1 is argument #2 of construct/2" do
    ## given
    check all e <- term(),
              l <- list_of(term()) do
      ## when
      s = Caffeine.Stream.construct(e, List.stream(l))
      ## then
      assert Caffeine.Stream.tail(s) == List.stream(l)
    end
  end
end
