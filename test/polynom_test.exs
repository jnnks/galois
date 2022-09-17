defmodule PolynomTest do
  use ExUnit.Case

  @tag :poly_init
  test "init polynom zeroth degree" do
    for i <- 0..9 do
      assert "#{i}" == Polynom.print([i])
    end
  end

  @tag :poly_init
  test "init polynom first degree" do
    assert "x" == Polynom.print([0, 1])
    assert "1 + x" == Polynom.print([1, 1])
  end

  @tag :poly_init
  test "init polynom second degree" do
    assert "x²" == Polynom.print([0, 0, 1])
    assert "1 + x²" == Polynom.print([1, 0, 1])
    assert "x + x²" == Polynom.print([0, 1, 1])
    assert "1 + x + x²" == Polynom.print([1, 1, 1])
  end
end

defmodule PolynomAddTest do
  use ExUnit.Case

  @tag :poly_add
  test "add polynom zeroth degree" do
    for l <- 0..100, r <- 0..100 do
      assert [l] == [l] |> Polynom.add([0])
      assert [l] == [0] |> Polynom.add([l])

      assert [l + r] == [l] |> Polynom.add([r])
      assert [l + r] == [r] |> Polynom.add([l])

      assert [0] == [l * -1] |> Polynom.add([l])
      assert [0] == [l] |> Polynom.add([l * -1])
    end
  end


  @tag :poly_add
  test "add polynom" do
    # (x5 + 3x3 + 4)+(6x6 + 4x3) = 6x6 + x5 + 7x3 + 4
    a =    [4,0,0,3,0,1]
    b =    [0,0,0,4,0,0,6]
    assert [4,0,0,7,0,1,6] == Polynom.add(a, b)
  end

  @tag :poly_sub
  test "sub polynom" do
    # (x5 + 3x3 + 4)-(6x6 + 4x3) = -6x6 + x5 -x3 + 4
    a =    [4,0,0, 3,0,1]
    b =    [0,0,0, 4,0,0, 6]
    assert [4,0,0,-1,0,1,-6] == Polynom.sub(a, b)
  end

  @tag :poly_mul
  test "mul polynom" do
    # (x5 + 3x3 + 4)*(6x6 + 4x3) = 6x11 + 18x9 + 4x8 + 36x6 + 16x3
    a =    [4,0,0,3,0,1]
    b =    [0,0,0,4,0,0,6]
    assert [0,0,0,16,0,0,36,0,4,18,0,6] == Polynom.mul(a, b)
  end

  @tag :poly_div
  test "div polynom" do
    # (6x11 + 18x9 + 4x8 + 36x6 + 16x3) ÷ (x5 + 3x3 + 4) = 6x6 + 4x3
    a =    [0,0,0,16,0,0,36,0,4,18,0,6]
    b =    [4,0,0,3,0,1]
    assert {[0,0,0,4,0,0,6], [0]} == Polynom.div(a, b)

    #  (3x6 + 7x4 + 4x3 + 5) ÷ (x4 + 3x3 + 4) = 3x2 - 9x + 34
    #    rem: -98x3 - 12x2 + 26x -131
    a =    [5,0,0,4,7,0,3]
    b =    [4,0,0,3,1]
    assert {[34,-9,3], [-131,36,-12,-98]} == Polynom.div(a, b)
  end

  @tag :poly_mod
  test "mod polynom" do
    assert [0,-1,1,1] == Polynom.poly_mod([0,0,1,1,1,1], [1,0,0,1,1])
    assert [0,1,1,1] == Polynom.int_mod([0,-1,1,1], 2)
  end

  @tag :poly_add
  test "add polynom first degree" do
    for l <- 1..100, r <- 1..100 do
      assert [0, l] == [0, l] |> Polynom.add([0, 0])
      assert [0, l] == [0, 0] |> Polynom.add([0, l])

      assert [0, l + r] == [0, l] |> Polynom.add([0, r])
      assert [0, l + r] == [0, r] |> Polynom.add([0, l])

      assert [0] == [0, l * -1] |> Polynom.add([0, l])
      assert [0] == [0, l] |> Polynom.add([0, l * -1])
    end
  end

  @tag :poly_add
  test "add polynom nth degree" do
    for e <- 0..100 do
      zeros = for _ <- 0..e, do: 0
      assert zeros ++ [4] == zeros ++ [2]  |> Polynom.add(zeros ++ [2])
    end
  end
end

defmodule PolynomDivTest do
  use ExUnit.Case
  # doctest CodingTheory

  @tag :poly_div
  test "div polynom first degree" do
    assert_raise ArgumentError, fn -> Polynom.div([0], [0]) end
    assert {[1], [0]} == [1] |> Polynom.div([1])
    assert {[0, 1], [0]} == Polynom.div([0, 1], [1])

    assert {[-6, -1, 1], [0]} == Polynom.div([6, -5, -2, 1], [-1, 1])
    assert {[4, -1, 3],[0]} == Polynom.div([-12, 7, -10, 3], [-3, 1])

    assert {[2],[1]} == Polynom.div([5], [2])
    assert {[0],[1,1]} == Polynom.div([1,1], [2,2])

    # from script: 4.10 1 + 2x + x3 + 2x4  /  2 + x + x2
    assert {[-3, -1, 2], [7, 7]} == Polynom.div([1,2,0,1,2],[2,1,1])
  end
end

defmodule PolynomMulTest do
  use ExUnit.Case
  # doctest CodingTheory

  @tag :poly_mul
  test "mul polynom zeroth degree" do
    for l <- 0..100, r <- 0..100 do
      assert [0] == [l] |> Polynom.mul([0])
      assert [0] == [0] |> Polynom.mul([l])

      assert [l] == [l] |> Polynom.mul([1])
      assert [l] == [1] |> Polynom.mul([l])

      assert [l * r] == [l] |> Polynom.mul([r])
      assert [l * r] == [r] |> Polynom.mul([l])
    end
  end

  @tag :poly_mul
  test "mul polynom first degree" do

    for l <- 1..100, r <- 1..100 do
      assert [0, 0, 0] == [l, r] |> Polynom.mul([0, 0])
      assert [0, 0, 0] == [0, 0] |> Polynom.mul([l, r])

      assert [l, r] == [l, r] |> Polynom.mul([1])
      assert [l, r] == [1] |> Polynom.mul([l, r])
      assert [l, l + r, r] == [l, r] |> Polynom.mul([1, 1])
      assert [l, l + r, r] == [1, 1] |> Polynom.mul([l, r])

      # first binomic formula
      assert [l*l, 2*l*r, r*r] == [l, r] |> Polynom.mul([l, r])
      assert [r*r, 2*r*l, l*l] == [r, l] |> Polynom.mul([r, l])

      assert [l*r, r*r + l*l, r*l] == [l, r] |> Polynom.mul([r, l])
    end
  end

  @tag :poly_mul
  test "polynom multiply" do
    for e <- 0..100 do
      zeros = for _ <- 0..e, do: 0
      assert [4] ++ zeros ++ zeros == [2] ++ zeros |> Polynom.mul([2] ++ zeros)
    end
  end
end
