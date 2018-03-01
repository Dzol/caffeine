defmodule Caffeine.StreamTest do
  use ExUnit.Case
  doctest Caffeine.Stream

  test "a constant stream of any term" do
    ## given
    defmodule Constant do
      def stream(x) do
        [x | rest(x)]
      end

      defp rest(x) do
        fn -> stream(x) end
      end
    end

    ## when
    s = Constant.stream(3.14159265359)
    l = Caffeine.Stream.take(s, 5)
    ## then
    assert length(l) === 5
    assert Enum.all?(l, &pi?/1)
  end

  defp pi?(n) do
    n === 3.14159265359
  end
end
