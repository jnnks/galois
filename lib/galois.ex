

defmodule GF do
  @moduledoc """
  Construct finite fields and do basic arithmetic inside them.

      iex> gf = GF.new(2, 2)
      iex> GF.add(gf, 2, 2)
      0
      iex> GF.sub(gf, 2, 2)
      0
      iex> GF.mul(gf, 2, 2)
      3
      iex> GF.div(gf, 2, 2)
      1
      iex> GF.pow(gf, 2, -1)
      3

  """

  defstruct [:p, :e, :irp]

  @doc """
  Construct a new Field.
  Irreducible polynomials are provided for GF(2), GF(3), GF(5), GF(7), GF(11), each with extensions from 1 to 4.

      iex> GF.new(2, 2)
      %GF{p: 2, e: 2, irp: [1, 1, 1]}

  You can provide your own polynomials too.
  There is no specialized struct for polynoms and they are plain elixir lists.
  Coefficients are sorted by their exponents ascending.

      iex> Polynom.print([1,0,0,1,1])
      "1 + x³ + x⁴"
      iex> GF.new(2, 4, [1,0,0,1,1])
      %GF{p: 2, e: 4, irp: [1, 0, 0, 1, 1]}

  """
  @spec new(pos_integer, pos_integer) :: %GF{}
  def new(characteristic, extension \\ 1),
    do: %GF{
      p: characteristic,
      e: extension,
      irp: GF.IrreduciblePolynomials.for(characteristic, extension)
    }
  @spec new(pos_integer, pos_integer, list(pos_integer)) :: %GF{}
  def new(characteristic, extension, irreducible_polynomial),
    do: %GF{
      p: characteristic,
      e: extension,
      irp: irreducible_polynomial
    }

  @doc """
  Add two numbers inside the field.
  If either of the numbers or the result are not part of the fields elements, it will be converted accordingly.

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.add(gf,2,2)
      0
      iex(2)> GF.add(gf,2,4)
      # 4 is not part of (0,1,2,3) -> 4 mod 4 = 0
      2

  """
  @spec add(%GF{}, pos_integer, pos_integer) :: pos_integer
  def add(_gf, a, 0), do: a
  def add(_gf, 0, b), do: b
  def add(gf, a, b), do: inside_field(gf, &Polynom.add/2, [a, b])


  @doc """
  Subtract two numbers inside the field.
  If either of the numbers or the result are not part of the fields elements, it will be converted accordingly.

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.sub(gf,2,2)
      0
      iex(2)> GF.sub(gf,5,2)
      # 5 is not part of (0,1,2,3)
      #     5 mod 4 =  1,
      #       1 - 2 = -1
      #    (-1 + 4) =  3
      3

  """
  @spec sub(%GF{}, pos_integer, pos_integer) :: pos_integer
  def sub(_gf, a, 0), do: a
  def sub(gf, a, b), do: inside_field(gf, &Polynom.sub/2, [a, b])

  @doc """
  Multiply two numbers inside the field.
  If either of the numbers or the result are not part of the fields elements, it will be converted accordingly using the polynomial basis.

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.mul(gf,2,2)
      3

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.mul(gf,2,5)
      2

  """
  @spec mul(%GF{}, pos_integer, pos_integer) :: pos_integer
  def mul(_gf, a, 1), do: a
  def mul(_gf, 1, b), do: b
  def mul(gf, a, b), do: inside_field(gf, &Polynom.mul/2, [a, b])


  @doc """
  Divide two numbers inside the field.
  If either of the numbers or the result are not part of the fields elements, it will be converted accordingly using the polynomial basis.
  Division is based on the multiplicative inverse.

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.div(gf,2,2)
      1

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.div(gf,2,5)
      2

  """
  @spec div(%GF{}, pos_integer, pos_integer) :: pos_integer
  def div(_gf, a, 1), do: a
  def div(gf, a, b), do: mul(gf, a, mul_inv(gf, b))


  @doc """
  Raise number to power inside the field.
  If the base is not part of the fields elements, it will be converted accordingly.
  The extension is not considered as a part of the fields elements and will not be converted.

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.pow(gf,2,2)
      3

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.pow(gf,3,5)
      2

      iex(2)> gf = GF.new(2,2)
      iex(2)> GF.pow(gf,3,-1)
      # 2 is multiplicative inverse of 3 inside field
      2
  """
  @spec pow(%GF{}, pos_integer, integer) :: pos_integer
  def pow(_gf, _n, 0), do: 1
  def pow(_gf, n, 1), do: n
  def pow(gf, n, e) when e > 1,
    # multiply  n  e-times with itself
    do: Enum.reduce(2..e, n, fn _e, acc -> GF.mul(gf, acc, n) end)
  def pow(gf, n, -1), do: GF.mul_inv(gf, n)
  def pow(gf, n, e) when e < 0,
    # get inverse (n^-1) then multiply it (-1 * e)-times with itself
    do: GF.pow(gf, GF.mul_inv(gf, n), e * -1)

  @doc """
  Calculate the multiplicative inverse of a number inside the field.
  The algorithms uses `a^-1 == a^(p-2)` as a basis of conversion.
  This function may be less performant compared to `GF.Algorithms.itoh_tsujii` which solves the same problem.
  """
  @spec mul_inv(%GF{}, pos_integer) :: pos_integer
  def mul_inv(_gf, 1), do: 1
  def mul_inv(gf=%GF{p: p, e: e}, n), do: GF.pow(gf, n, (trunc(:math.pow(p, e)) - 2))


  @doc """
  Calculate the additive inverse of a number inside the field.
  """
  @spec add_inv(%GF{}, pos_integer) :: pos_integer
  def add_inv(%GF{p: p, e: 1}, n), do: p - Kernel.rem(n, p)
  def add_inv(gf=%GF{p: p}, n), do: sub(gf, p, Kernel.rem(n, p))

  # convert parameters into field elements in polynomial representation and pass them to `fun`
  defp inside_field(gf =%GF{}, fun, args) do
    args = Enum.map(args, &into_polynom(&1, gf))
    apply(fun, args)
    |> into_decimal(gf)
  end

  # convert field element into polynomial
  defp into_polynom(dec_num,%GF{p: p, e: e}),
    do: rem(dec_num, trunc(:math.pow(p, e)))
      |> Integer.digits(p)
      |> Enum.reverse()

  # convert polynomial into field element
  defp into_decimal(polynom,%GF{p: p, irp: irp}), do:
    polynom
    |> Polynom.poly_mod(irp)
    |> Enum.map(fn coeff ->
      coeff = if coeff < 0, do: trunc(coeff + p * abs(coeff)), else: coeff
      rem(coeff, p)
    end)
    |> Enum.reverse()
    |> Integer.undigits(p)
end

defmodule GF.IrreduciblePolynomials do
  def for(2, 1), do: [1, 1] # x + 1
  def for(2, 2), do: [1, 1, 1] # x^2 + x + 1
  def for(2, 3), do: [1, 1, 0, 1] # x^3 + x + 1
  def for(2, 4), do: [1, 1, 0, 0, 1] # x^4 + x + 1
  def for(3, 1), do: [1, 1] # x + 1
  def for(3, 2), do: [2, 2, 1] # x^2 + 2x + 2
  def for(3, 3), do: [1, 2, 0, 1] # x^3 + 2x + 1
  def for(3, 4), do: [2, 0, 0, 2, 1] # x^4 + 2x^3 + 2
  def for(5, 1), do: [3, 1] # x + 3
  def for(5, 2), do: [2, 4, 1] # x^2 + 4x + 2
  def for(5, 3), do: [3, 3, 0, 1] # x^3 + 3x + 3
  def for(5, 4), do: [2, 4, 4, 0, 1] # x^4 + 4x^2 + 4x + 2
  def for(7, 1), do: [4, 1] # x + 4
  def for(7, 2), do: [3, 6, 1] # x^2 + 6x + 3
  def for(7, 3), do: [4, 0, 6, 1] # x^3 + 6x^2 + 4
  def for(7, 4), do: [3, 4, 5, 0, 1] # x^4 + 5x^2 + 4x + 3
  def for(11, 1), do: [9, 1] # x + 9
  def for(11, 2), do: [2, 7, 1] # x^2 + 7x + 2
  def for(11, 3), do: [9, 2, 0, 1] # x^3 + 2x + 9
  def for(11, 4), do: [2, 10, 8, 0, 1] # x^4 + 8x^2 + 10x + 2
  def for(_c, _e), do: raise "Cannot provide irreducible polynom for characteristic and extension. Please provide it yourself"
end


defmodule GF.Algorithms do
  @doc """
  Itoh-Tsujii Algorithm to find multiplicative inverses in a finite field.
  https://en.wikipedia.org/wiki/Itoh-Tsujii_inversion_algorithm
  """
  @spec itoh_tsujii(%GF{e: pos_integer, p: pos_integer}, pos_integer) :: pos_integer
  def itoh_tsujii(_gf, 1), do: 1
  def itoh_tsujii(gf =%GF{p: p, e: m}, a) do
    # r = (p^m − 1) / (p − 1)
    #   NOTE: _not_ inside field
    r = div(trunc(:math.pow(p, m)) - 1, (p - 1))

    # compute a^(r − 1) in GF(p^m)
    a_r1 = GF.pow(gf, a, (r - 1))

    # compute a^r = a^(r − 1) · a
    ar =  GF.mul(gf, a_r1, a)

    # compute (a^r)^−1 in GF(p)
    a_r_1 = GF.pow(GF.new(p), ar, p-2)

    # return a^−1 = (a^r)^−1 · a^(r−1)
    rem(GF.mul(gf, a_r_1, a_r1), trunc(:math.pow(p, m)))
  end
end
