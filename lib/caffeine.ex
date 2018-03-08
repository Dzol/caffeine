defmodule Caffeine do
  @moduledoc """
  ![Coffee Bean Boundary](./coffee.jpeg)

  A stream library with an emphasis on simplicity
  """

  defmodule Stream do
    @moduledoc """
    Find the API under this module
    """

    @typedoc """
    The Caffeine.Stream data structure
    """
    @opaque t :: nonempty_improper_list(term, (() -> t)) | []

    @doc """
    A special value whose presence signals the end of a stream
    """
    @spec sentinel() :: []
    def sentinel do
      []
    end

    @doc """
    A predicate to test for the sentinel value
    """
    @spec sentinel?(t) :: boolean
    def sentinel?([]) do
      true
    end

    def sentinel?([_ | x]) when is_function(x, 0) do
      false
    end

    @doc """
    Predicate: is this a stream of at least one element?
    """
    @spec construct?(t) :: boolean
    def construct?([_ | x]) when is_function(x, 0) do
      true
    end

    def construct?([]) do
      false
    end

    @doc """
    A stream of at least one element
    """
    def construct(x, y) when is_function(y, 0) do
      pair(x, y)
    end

    @doc """
    A list of consecutive elements of the stream
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
    An element-wise transformation
    """
    @spec map(t, (term -> term)) :: t
    def map(s, f) do
      # import Caffeine.Stream, only: [sentinel?: 1, construct?: 1, sentinel: 0, construct: 2]

      cond do
        sentinel?(s) ->
          sentinel()

        construct?(s) ->
          g = fn -> map(tail(s), f) end
          construct(f.(head(s)), g)
      end
    end

    @doc """
    The head, if any, of the stream
    """
    @spec head(t) :: term
    def head([h | t]) when is_function(t, 0) do
      h
    end

    @doc """
    The tail, if any, of the stream
    """
    @spec tail(t) :: t
    def tail([_ | t]) when is_function(t, 0) do
      t.()
    end

    defp pair(h, r) do
      [h | r]
    end
  end
end
