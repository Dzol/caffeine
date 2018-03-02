defmodule Caffeine do
  defmodule Stream do
    @moduledoc """
    ![Coffee Bean Boundary](./coffee.jpeg)

    A stream library with an emphasis on simplicity
    """

    @typedoc """
    The stream data-structure
    """
    @type t :: nonempty_improper_list(term, function) | []

    def sentinel do
      []
    end

    def sentinel?(x) do
      x == []
    end

    defmacro construct(x, y) do
      quote do
        [unquote(x) | fn -> unquote(y) end]
      end
    end

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

    @doc """
    A simple map

    The output stream is the input stream w/ the function _f_ applied to each of the elements.
    """
    @spec map(t, (term -> term)) :: t
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
