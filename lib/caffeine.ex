defmodule Caffeine do
  defmodule Stream do
    @moduledoc """
    An interface for the lazy embedding we use as a stream
    """

    @typedoc """
    The structure of the stream

    Though it could be more of an ADT there are no `hold/1` and `release/1` macros with which to build a constructor (yet).
    A plain old anonymous function and an `apply/2` suffice for the time being at least 🙂
    The list `[]` acts as the sentinel for the stream too.
    """
    @type t :: nonempty_improper_list(term, function) | []

    @doc """
    Extracts _n_ consecutive elements from the stream

    A list of less than _n_ elements out if it reaches the sentinel.
    """
    @spec take(t, integer) :: list
    def take([], _) do
      []
    end

    def take(_, 0) do
      []
    end

    def take(x, n) when is_integer(n) and n > 0 do
      [head(x) | take(tail(x), n - 1)]
    end

    def map([], _) do
      []
    end

    def map(s, f) when is_list(s) and is_function(tl(s)) and is_function(f, 1) do
      head = apply(f, [head(s)])
      rest = fn -> map(tail(s), f) end
      [head | rest]
    end

    @spec head(t) :: term
    defp head(x) do
      hd(x)
    end

    @spec tail(t) :: t
    defp tail(x) do
      apply(tl(x), [])
    end
  end
end
