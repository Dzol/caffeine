defmodule CaffeineTest.Ancillary.List do
  require Caffeine.Stream

  def stream([]) do
    import Caffeine.Stream, only: [sentinel: 0]

    sentinel()
  end

  def stream(l) when is_list(l) do
    import Caffeine.Stream, only: [construct: 2]

    f = fn -> stream(tl(l)) end
    construct(hd(l), f)
  end
end
