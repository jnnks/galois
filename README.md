# Galois Finite Field Arithmetic
Simple arithmetic operations (`+`, `-`, `*`, `/`) over prime/extended fields using polynomial basis.
There is no distincion between prime- and extension fields and so no optimization has been done. Furthermore all calculations are done using standard elixir numbers. `GF(2^e)` will not use any binary operations.
An eventual feature update may bring Nx like backends where such optimizations could take place.


Irreducible polynomials are automatically provided for GF(2), GF(3), GF(5), GF(7), GF(11), each with extensions from 1 to 4 (see `GF.IrreduciblePolynomials`). Custom ones can be provided via the Field contructor.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `galois` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:galois, "~> 0.0.1"}
  ]
end
```