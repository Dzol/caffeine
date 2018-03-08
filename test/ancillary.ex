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
