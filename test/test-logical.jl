using SymPyPythonCall
using Test

@testset "Logical" begin
    ## More logical expressions
    @syms x y
    (x ≪ 0) ∧ Le(x*y,1) ∨ (x ⩵ y) ∧ (¬(x ≫ 3))
end
