defmodule Polynom do
  defstruct [:coeffs, :modulo]

  defp zip(lhs, rhs) when length(lhs) == length(rhs), do: Enum.zip([lhs, rhs])

  defp zip(lhs, rhs) do
    pad_len = abs(length(lhs) - length(rhs))
    pad = for _ <- 1..pad_len, do: 0
    [lhs, rhs] = if length(lhs) < length(rhs), do: [lhs ++ pad, rhs], else: [lhs, rhs ++ pad]
    Enum.zip([lhs, rhs])
  end

  def add(lhs, rhs),
    # component wise addition
    do:
      (for {l, r} <- zip(lhs, rhs), do: l + r)
      |> reduce()

  def sub(lhs, rhs),
    # component wise subtraction
    do:
      (for {l, r} <- zip(lhs, rhs), do: l - r)
      |> reduce()

  def mul(lhs, rhs) do
    # cartesian product of all coeffs with their exponent
    for {l, le} <- Enum.with_index(lhs),
        {r, re} <- Enum.with_index(rhs) do
      {{l, le}, {r, re}}
    end
    # build map containing "exponent => [coefficients]"
    |> Enum.reduce(%{}, fn {{l, le}, {r, re}}, acc ->
      addends = [l * r | Map.get(acc, le + re, [])]
      Map.put(acc, le + re, addends)
    end)
    |> Map.to_list()
    # sort terms ascending, so we can insert the coeffs in the next step
    # --> polynom is built from high exp to low exp
    |> Enum.sort(fn {le, _l}, {re, _r} -> le > re end)
    |> Enum.reduce([], fn {_exp, addends}, coeffs ->
      [Enum.sum(addends) | coeffs]
    end)
  end

  # division by zero
  def div(poly, [0]) when is_list(poly), do: raise(ArgumentError, "divisor is zero")

  # cannot divide, rhs is too big
  def div(lhs, rhs) when length(lhs) < length(rhs), do: {[0], lhs}
  def div(lhs, rhs) when length(lhs) == length(rhs) and hd(lhs) < hd(rhs), do: {[0], lhs}

  # same polynom
  def div(poly, poly), do: {[1], [0]}

  # regular main entry
  #   polynoms are sorted from x^0 to x^n, we need to reverse,
  #   so we can easily get the coefficient with the highest exponent with pattern matching
  def div(lhs, rhs) do
    {q, rest} = div(lhs |> Enum.reverse(), rhs |> Enum.reverse(), [])
    q = q |> Enum.reverse() |> Enum.drop_while(&(&1 == 0)) |> Enum.reverse()

    rest = rest |> Enum.reverse() |> Enum.drop_while(&(&1 == 0)) |> Enum.reverse()
    rest = if rest == [], do: [0], else: rest

    {q, rest}
  end

  # no remainder -> division without rest
  defp div([], _rhs, result), do: {result, [0]}
  # remainder left and irr poly has higher exp -> division with rest
  defp div(lhs, rhs, result) when length(lhs) < length(rhs),
    do: {result, lhs |> Enum.reverse()}
  # division by single zero-exp coefficient
  defp div([l], [r], result),
    do: {[Kernel.div(l, r) | result], [Kernel.rem(l, r)]}
  # division in progress
  defp div([l | ltl], [r | rtl] = rhs, result) do
    # divide highest power coeffs
    quotient = Kernel.div(l, r)

    # multiply rhs with quotient and subtract element-wise from lhs
    #   we do not want to pad this zip, only pair up as many coeffs, as the divisor has
    head =
      Enum.zip(ltl, rtl)
      |> Enum.reduce([], fn {l, r}, acc ->
        [l - quotient * r | acc]
      end)
      |> Enum.reverse()

    # build remaining lhs
    #   drop outdated coeffs
    tail = Enum.drop(ltl, length(head))

    div(head ++ tail, rhs, [trunc(quotient) | result])
  end

  def poly_mod([], _irr_pol), do: []
  def poly_mod(_pol, []), do: []

  def poly_mod(pol, irr_pol) do

    [ll, rl] = [pol, irr_pol] |> Enum.map(&length(&1))

    cond do
      ll < rl -> pol

      ll >= rl ->
        {_p, remainder} = Polynom.div(pol, irr_pol)
        if length(remainder) < length(irr_pol) do
          remainder
        else
          [e | _] = remainder |> Enum.reverse()
          [ie | _] = irr_pol |> Enum.reverse()
          difference = abs(Kernel.div(e, ie))
          sub(remainder, mul(irr_pol, [difference]))
        end
    end
  end

  def int_mod(pol, modulus) do
    for c <- pol do
      if c < 0,
        do: rem(c + modulus, modulus),
        else: rem(c, modulus)
    end
  end

  def print(poly) do
    term =
      poly
      |> Enum.with_index()
      # drop zeros
      |> Enum.filter(fn {c, _e} -> c > 0 end)
      |> Enum.map(fn {c, e} ->
        cond do
          e == 0 -> "#{c}"
          e == 1 and c == 1 -> "x"
          e == 1 -> "#{c}x"
          c == 1 -> "x" <> exponents(e)
        end
      end)
      |> Enum.join(" + ")

    if term == "", do: "0", else: term
  end

  defp exponents(e), do: Enum.at(~w"⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹", e)

  defp reduce(polynom) do
    dropped = polynom
      |> Enum.reverse()
      |> Enum.drop_while(&(&1 == 0))
      |> Enum.reverse()
    if dropped == [], do: [0], else: dropped
  end
end
