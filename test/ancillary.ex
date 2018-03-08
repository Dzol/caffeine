defmodule CaffeineTest.Ancillary.Natural do
  require Caffeine.Stream

  def lazy do
    lazy(0)
  end

  defp lazy(n) do
    f = fn ->
      lazy(increment(n))
    end

    Caffeine.Stream.construct(n, f)
  end

  defp increment(n) do
    n + 1
  end
end

defmodule CaffeineTest.Ancillary.List do
  require Caffeine.Stream

  def stream([]) do
    Caffeine.Stream.sentinel()
  end

  def stream(l) when is_list(l) do
    f = fn ->
      stream(tl(l))
    end

    Caffeine.Stream.construct(hd(l), f)
  end
end
