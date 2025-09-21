defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  This Modul serves the purpose of generating CPU load.
  """

  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) when limit == 1 do
    []
  end

  def primes_to(limit) when limit >= 2 do
    sieve(Enum.to_list(2..limit))
  end

  defp sieve([]), do: []

  defp sieve([p | rest]) do
    # p ist die nächste Primzahl
    [p | sieve(remove_multiples(rest, p))]
  end

  defp remove_multiples(nums, p) do
    Enum.reject(nums, fn n -> multiple?(n, p) end)
  end

  defp multiple?(n, p) do
    IO.inspect(n, label: "n", charlists: :as_list)
    IO.inspect(p, label: "p", charlists: :as_list)

    Stream.iterate(p, &(&1 + p))
    |> Enum.take_while(&(&1 <= n))
    |> IO.inspect(label: "multiples", charlists: :as_list)
    |> Enum.any?(&(&1 == n))
  end
end
