defmodule Caffeine do
  @moduledoc """
  ![Coffee Bean Boundary](./coffee.jpeg)

  An alternative stream library

  Find the API under `Caffeine.Stream`.
  """

  defmodule Element do
    @type t :: term
  end

  defmodule Stream do
    @moduledoc """
    Primitives and HOFs

    ## Examples

        iex> defmodule Fibonacci do
        ...>   import Caffeine.Stream, only: [construct: 2]
        ...> 
        ...>   def stream do
        ...>     stream(0, 1)
        ...>   end
        ...> 
        ...>   defp stream(a, b) do
        ...>     rest = fn -> stream(b, a + b) end
        ...>     construct(a, rest)
        ...>   end
        ...> end
        iex> require Integer
        iex> Fibonacci.stream()
        ...> |> Caffeine.Stream.filter(&Integer.is_even/1)
        ...> |> Caffeine.Stream.map(&Integer.to_string/1)
        ...> |> Caffeine.Stream.take(10)
        ["0", "2", "8", "34", "144", "610", "2584", "10946", "46368", "196418"]

    """

    @typedoc """
    The Caffeine.Stream data structure
    """
    @opaque t :: nonempty_improper_list(Element.t(), (() -> t)) | []

    @doc """
    This signals the end of a stream

    Don't count on `sentinel/0` returning a `[]`.
    SoE: how can we do this with a Dialyzer declaration?
    """
    @spec sentinel() :: []
    def sentinel do
      []
    end

    @doc """
    Predicate: is _s_ the sentinel?

    ## Examples

        iex> import Caffeine.Stream, only: [sentinel?: 1, sentinel: 0, construct: 2]
        Caffeine.Stream
        iex> sentinel?(sentinel())
        true
        iex> sentinel?(construct("Elixir", fn -> sentinel() end))
        false

    """
    @spec sentinel?(t) :: boolean
    def sentinel?(s)

    def sentinel?([]) do
      true
    end

    def sentinel?([_ | x]) when is_function(x, 0) do
      false
    end

    @doc """
    Predicate: is _s_ a stream of at least one element?

    ## Examples

        iex> import Caffeine.Stream, only: [construct?: 1, sentinel: 0, construct: 2]
        Caffeine.Stream
        iex> construct?(construct("Elixir", fn -> sentinel() end))
        true
        iex> construct?(sentinel())
        false

    """
    @spec construct?(t) :: boolean
    def construct?(s)

    def construct?([_ | x]) when is_function(x, 0) do
      true
    end

    def construct?([]) do
      false
    end

    @doc """
    A stream of at least one element _h_
    """
    @spec construct(Element.t(), (() -> t)) :: t
    def construct(h, t) when is_function(t, 0) do
      pair(h, t)
    end

    @doc """
    A list of _n_ consecutive elements from the stream _s_

    ## Examples

        iex> defmodule Natural do
        ...>   import Caffeine.Stream, only: [construct: 2]
        ...> 
        ...>   def stream do
        ...>     stream(0)
        ...>   end
        ...> 
        ...>   defp stream(n) do
        ...>     rest = fn -> stream(increment(n)) end
        ...>     construct(n, rest)
        ...>   end
        ...> 
        ...>   defp increment(n) do
        ...>     n + 1
        ...>   end
        ...> end
        iex> Caffeine.Stream.take(Natural.stream(), 5)
        [0,1,2,3,4]

    """
    @spec take(t, integer) :: list
    def take([], _) do
      []
    end

    def take(_, 0) do
      []
    end

    def take(s, n) when is_integer(n) and n > 0 do
      [head(s) | take(tail(s), n - 1)]
    end

    @doc """
    Like the stream _s_ with the function _f_ applied to each element

    ## Examples

        iex> defmodule Natural do
        ...>   import Caffeine.Stream, only: [construct: 2]
        ...> 
        ...>   def stream do
        ...>     stream(0)
        ...>   end
        ...> 
        ...>   defp stream(n) do
        ...>     rest = fn -> stream(increment(n)) end
        ...>     construct(n, rest)
        ...>   end
        ...> 
        ...>   defp increment(n) do
        ...>     n + 1
        ...>   end
        ...> end
        iex> Natural.stream()
        ...> |> Caffeine.Stream.map(&Integer.to_string/1)
        ...> |> Caffeine.Stream.take(5)
        ["0","1","2","3","4"]

    """
    @spec map(t, (Element.t() -> Element.t())) :: t
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
    A stream whose elements prescribe to the predicate _p_

    ## Examples

        iex> defmodule Natural do
        ...>   import Caffeine.Stream, only: [construct: 2]
        ...> 
        ...>   def stream do
        ...>     stream(0)
        ...>   end
        ...> 
        ...>   defp stream(n) do
        ...>     rest = fn -> stream(increment(n)) end
        ...>     construct(n, rest)
        ...>   end
        ...> 
        ...>   defp increment(n) do
        ...>     n + 1
        ...>   end
        ...> end
        iex> require Integer
        iex> Natural.stream()
        ...> |> Caffeine.Stream.filter(&Integer.is_even/1)
        ...> |> Caffeine.Stream.take(5)
        [0,2,4,6,8]

    """
    @spec filter(t, (Element.t() -> boolean)) :: t
    def filter(s, p) do
      # import Caffeine.Stream, only: [sentinel?: 1, construct?: 1, sentinel: 0, construct: 2]

      cond do
        sentinel?(s) ->
          sentinel()

        construct?(s) ->
          _filter(s, p)
      end
    end

    @doc """
    The head, if any, of the stream _s_

    The following always holds true `head(construct(X, Y)) == X`.

    ## Examples

        iex> import Caffeine.Stream, only: [head: 1, sentinel: 0, construct: 2]
        Caffeine.Stream
        iex> h = "Elixir"
        iex> t = fn -> sentinel() end
        iex> s = construct(h, t)
        iex> head(s) == h
        true

    """
    @spec head(t) :: Element.t()
    def head(s)

    def head([h | t]) when is_function(t, 0) do
      h
    end

    @doc """
    The tail, if any, of the stream _s_

    The following always holds true `tail(construct(X, Y)) == Y.()`.

    ## Examples

        iex> import Caffeine.Stream, only: [tail: 1, sentinel: 0, construct: 2]
        Caffeine.Stream
        iex> h = "Elixir"
        iex> t = fn -> sentinel() end
        iex> s = construct(h, t)
        iex> tail(s) == sentinel()
        true

    """
    @spec tail(t) :: t
    def tail(s)

    def tail([_ | t]) when is_function(t, 0) do
      t.()
    end

    @doc """
    Given a stream skips n consecutive elements of it 

    ## Examples

        iex> defmodule Natural do
        ...>   import Caffeine.Stream, only: [construct: 2]
        ...> 
        ...>   def stream do
        ...>     stream(0)
        ...>   end
        ...> 
        ...>   defp stream(n) do
        ...>     rest = fn -> stream(increment(n)) end
        ...>     construct(n, rest)
        ...>   end
        ...> 
        ...>   defp increment(n) do
        ...>     n + 1
        ...>   end
        ...> end
        iex> Natural.stream()
        ...> |> Caffeine.Stream.skip(5)
        ...> |> Caffeine.Stream.take(5)
        [5, 6, 7, 8, 9]

    """
    @spec skip(t, integer) :: t
    def skip(s, 0) do
      s
    end

    def skip(s, n) when is_integer(n) and n > 0 do
      cond do
        sentinel?(s) ->
          sentinel()

        construct?(s) ->
          skip(tail(s), n - 1)
      end
    end
    
    defp pair(h, r) do
      [h | r]
    end

    defp _filter(s, p) do
      if p.(head(s)) do
        g = fn -> filter(tail(s), p) end
        construct(head(s), g)
      else
        filter(tail(s), p)
      end
    end
  end
end
