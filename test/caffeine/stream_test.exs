defmodule Caffeine.StreamTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Caffeine.Stream

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
    check all e <- term(),
              l <- list_of(term()) do
      ## given
      r = List.stream(l)
      ## when
      s = Caffeine.Stream.construct(e, r)
      ## then
      assert Caffeine.Stream.head(s) == e
    end
  end

  property "tail/1 is argument #2 of construct/2" do
    check all e <- term(),
              l <- list_of(term()) do
      ## given
      r = List.stream(l)
      ## when
      s = Caffeine.Stream.construct(e, r)
      ## then
      assert Caffeine.Stream.tail(s) == List.stream(l)
    end
  end
end
