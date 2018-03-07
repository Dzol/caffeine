defmodule CaffeineTest.Ancillary.Natural do
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

defmodule CaffeineTest.Ancillary.List do
  require Caffeine.Stream

  def stream([]) do
    Caffeine.Stream.sentinel()
  end

  def stream(l) when is_list(l) do
    Caffeine.Stream.construct(hd(l), stream(tl(l)))
  end
end
