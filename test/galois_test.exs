defmodule FieldTest do
  use ExUnit.Case
  doctest GF

  @tag :field_irp
  test "GF irreducible Polynom not provided" do
    # gf = GF.new(5, 123)
  end

  @tag :gf_field_add
  test "field add table GF(4)" do

    # + | 0 1 2 3
    # --|---------
    # 0 | 0 1 2 3
    # 1 | 1 0 3 2
    # 2 | 2 3 0 1
    # 3 | 3 2 1 0

    gf = GF.new(2, 2, [1,1,1]) # 1 + x + x2
    assert 0 == GF.add(gf, 0, 0)
    assert 1 == GF.add(gf, 1, 0)
    assert 2 == GF.add(gf, 2, 0)
    assert 3 == GF.add(gf, 3, 0)

    assert 1 == GF.add(gf, 0, 1)
    assert 0 == GF.add(gf, 1, 1)
    assert 3 == GF.add(gf, 2, 1)
    assert 2 == GF.add(gf, 3, 1)

    assert 2 == GF.add(gf, 0, 2)
    assert 3 == GF.add(gf, 1, 2)
    assert 0 == GF.add(gf, 2, 2)
    assert 1 == GF.add(gf, 3, 2)

    assert 3 == GF.add(gf, 0, 3)
    assert 2 == GF.add(gf, 1, 3)
    assert 1 == GF.add(gf, 2, 3)
    assert 0 == GF.add(gf, 3, 3)
  end

  @tag :gf_mul
  test "field mul" do
    gf = GF.new(2, 4, [1,0,0,1,1]) # 1 + x3 + x4
    assert 14 == GF.mul(gf, 12, 5)

    ab_c = GF.mul(gf, GF.mul(gf, 2,3),4)
    a_bc = GF.mul(gf, 2, GF.mul(gf,3,4))
    assert ab_c == a_bc
  end

  @tag :field_mul
  test "field mul table GF(4)" do

    # · | 0 1 2 3
    # --|--------
    # 0 | 0 0 0 0
    # 1 | 0 1 2 3
    # 2 | 0 2 3 1
    # 3 | 0 3 1 2

    gf = GF.new(2, 2, [1,1,1]) # 1 + x + x2
    assert 0 == GF.mul(gf, 0, 0)
    assert 0 == GF.mul(gf, 1, 0)
    assert 0 == GF.mul(gf, 2, 0)
    assert 0 == GF.mul(gf, 3, 0)

    assert 0 == GF.mul(gf, 0, 1)
    assert 1 == GF.mul(gf, 1, 1)
    assert 2 == GF.mul(gf, 2, 1)
    assert 3 == GF.mul(gf, 3, 1)

    assert 0 == GF.mul(gf, 0, 2)
    assert 2 == GF.mul(gf, 1, 2)
    assert 3 == GF.mul(gf, 2, 2)
    assert 1 == GF.mul(gf, 3, 2)

    assert 0 == GF.mul(gf, 0, 3)
    assert 3 == GF.mul(gf, 1, 3)
    assert 1 == GF.mul(gf, 2, 3)
    assert 2 == GF.mul(gf, 3, 3)
  end
end
