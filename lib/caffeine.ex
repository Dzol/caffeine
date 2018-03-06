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
    A stream whose head is the element _e_ and whose tail _s_ is the expression to generate successive elements

    **Warning:** don't pass a variable through the _s_ argument.
    """
    @spec construct(term, t) :: t
    defmacro construct(e, s) do
      quote do
        [unquote(e) | fn -> unquote(s) end]
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

    @doc """
    The first element, if any, of the stream
    """
    @spec head(t) :: term
    def head(x) do
      hd(x)
    end

    @doc """
    The stream, if any, succeeding the first element
    """
    @spec tail(t) :: t
    def tail(x) do
      release(tl(x))
    end

    @spec release((() -> t)) :: t
    defp release(x) do
      x.()
    end
  end
end
