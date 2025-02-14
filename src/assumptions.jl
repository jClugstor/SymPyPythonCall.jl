## Assumptions
## http://docs.sympy.org/0.7.2/modules/assumptions/index.html

"""
     refine

Simplify an expression using assumptions; [refine](https://docs.sympy.org/dev/modules/assumptions/refine.html).
"""
refine(ex, assumpts...) = sympy.refine(ex, assumpts...)

"""
    ask(query)

Returns `true`, `false`, or `nothing`; [ask](https://docs.sympy.org/dev/modules/assumptions/ask.html)

Example:

```jldoctest ask
julia> using SymPyPythonCall

julia> @syms x::integer y::integer
(x, y)

julia> ask(𝑄.integer(x*y), sympy.And(𝑄.integer(x), 𝑄.integer(y)))
true

julia> filter(x -> ask(𝑄.prime(x)), 1:10) ## really slow isprime:
4-element Vector{Int64}:
 2
 3
 5
 7
```

"""
function ask(x::Sym, args...)
    val = sympy.ask(x, args...)
    Bool(Py(val) == pybuiltins.None) && return nothing
    Bool(Py(val) == pybuiltins.True) && return true
    Bool(Py(val) == pybuiltins.False) && return false
    throw(DomainError("Argument not none, true, or false"))
end

ask(x::Bool, args...) = x
ask(x::Nothing, args...) = x




# ## should we support & and | for (sym,sym) pairs? Not sure
# ## dependso on what happens to | (x==0) and ex == x usage for ==
# ## for now, we can combine terms logically with And, Or, Not...
# ## these are in logic module

# XXX This is from SymPy. Do we want this in SymPyPythonCall?

# ## We make a module Q to hold the assumptions
# ## this follows this page http://docs.sympy.org/0.7.5/_modules/sympy/assumptions/ask.html
# """
#     𝑄 [\itQ]
#     SymPy.Q

# Documentation for the `SymPy.Q` module, exported as `𝑄`.

# SymPy allows for
# [assumptions](https://docs.sympy.org/latest/modules/assumptions/index.html)
# on variables. These may be placed on free sympols at construction.

# For example, the following creates a real value variable `x` and a postive, real variable `y`:

# ```jldoctest 𝑄
# julia> using SymPy

# julia> @syms x::real
# (x,)

# julia> @syms y::(real,positive)
# (y,)
# ```

# The `Q` module exposes a means to *q*uery the assumptions on a
# variable. For example,

# ```jldoctest 𝑄
# julia> ask(𝑄.positive(y))  # true
# true

# julia> ask(𝑄.negative(y))  # false
# false

# julia> ask(SymPyPythonCall.Q.positive(x))  # `nothing`

# julia> ask(SymPyPythonCall..Q.positive(x^2)) # `nothing` -- might be 0

# julia> ask(SymPyPythonCall.Q.positive(1 + x^2)) # true  -- must be postive now.
# true
# ```

# The ask function uses tri-state logic, returning one of 3 values:
# `true`; `false`; or `nothing`, when the query is indeterminate.

# The construction of predicates is done through `Q` methods. These can
# be combined logically. For example, this will be `true`:

# ```jldoctest 𝑄
# julia> ask(𝑄.positive(y) & 𝑄.negative(-x^2 - 1))

# ```

# The above use `&` as an infix operation for the binary operator
# `And`. Values can also be combined with `Or`, `Not`, `Xor`, `Nand`,
# `Nor`, `Implies`, `Equivalent`, and `satisfiable`.

# !!! note "Matrix predicates"
#     As `SymPy.jl` converts symbolic matrices into Julia's `Array`
# type and not as matrices within Python, the predicate functions from SymPy for
# matrices are not used, though a replacement is given.
# """
# module Q
# import SymPyPythonCall: sympy
# import PythonCall
# import LinearAlgebra: det, norm

# ##http://docs.sympy.org/dev/_modules/sympy/assumptions/ask.html#ask
# Q_predicates = (:antihermitian,
#                 :bounded, :finite, # bounded deprecated
#                 :commutative,
#                 :complex,
#                 :composite,
#                 :even,
#                 :extended_real,
#                 :hermitian,
#                 :imaginary,
#                 :infinitesimal,
#                 :infinity, :infinite, # :infinity deprecated
#                 :integer,
#                 :irrational,
#                 :rational,
#                 :algebraic,
#                 :transcendental,
#                 :negative,
#                 :nonzero, :zero,
#                 :positive,
#                 :prime,
#                 :real,
#                 :odd,
#                 :is_true,
#                 :nonpositive,
#                 :nonnegative
# #                :symmetric,
# #                :invertible,
# #                :singular,
# #                :orthogonal,
# #                :unitary,
# #                :normal,
# #                :positive_definite,
# #                :upper_triangular,
# #                :lower_triangular,
# #                :diagonal,
# #                :triangular,
# #                :unit_triangular,
# #                :fullrank,
# #                :square,
# #                :real_elements,
# #                :complex_elements,
# #                :integer_elements
# )

# for meth in Q_predicates
#    nm = string(meth)
#       @eval begin
#           ($meth)(x) = sympy.Q.$(nm)(x)
#               #PyCall.pycall(SymPy.sympy.Q.$nm, SymPy.Sym, x)::SymPy.Sym
#    end
# end


# symmetric(M::Array{T,2}) where {T <: SymPyPythonCall.Sym} = SymPyPythonCall.issymmetric(M)
# function invertible(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     d = det(M)
#     pos = SymPyPythonCall.ask(positive(d))
#     if pos == nothing
#         return nothing
#     elseif pos == true
#         return true
#     end
#     neg = SymPyPythonCall.ask(negative(d))
#     if neg == nothing
#         return nothing
#     end
#     z = SymPyPythonCall.ask(zero(d))
#     if z == nothing
#         return nothing
#     elseif z == true
#         return false
#     end

#     return true
# end

# function singular(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     !invertible(M)
# end

# function orthogonal(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     vals = SymPyPythonCall.simplify.(SymPyPythonCall.simplify.(M*transpose(M)) .== one(T))
#     no_nothing = 0
#     for val in vals
#         a = SymPyPythonCall.ask(zero(val))
#         if a == nothing
#             no_nothing += 1
#         elseif a == false
#             return false
#         end
#     end

#     no_nothing > 0 && return nothing
#     return true
# end


# function unitary(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     vals = SymPyPythonCall.simplify.(SymPyPythonCall.simplify.(M*ctranspose(M)) .== one(T))
#     no_nothing = 0
#     for val in vals
#         a = SymPyPythonCall.ask(zero(val))
#         if a == nothing
#             no_nothing += 1
#         elseif a == false
#             return false
#         end
#     end

#     no_nothing > 0 && return nothing
#     return true
# end

# function normal(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     lhs = ctranspose(M) * M
#     rhs = M * ctranspose(M)
#     vals = zero.(SymPyPythonCall.simplify.(lhs - rhs))
#     no_nothing = 0
#     for val in vals
#         a = SymPyPythonCall.ask(val)
#         if a == nothing
#             no_nothing += 1
#         elseif a == false
#             return false
#         end
#     end

#     no_nothing > 0 && return nothing
#     return true
# end

# # Use [Sylvester's](https://en.wikipedia.org/wiki/Sylvester%27s_criterion) Criteria
# function positive_definite(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     !SymPyPythonCall.ask(square(M)) && return false
#     !SymPyPythonCall.ask(symmetric(M))  && return false
#     m, n = size(M)
#     no_false = 0
#     no_nothing = 0
#     for i in 1:m
#         a = SymPyPythonCall.ask(Q.positive(det(M[1:i, 1:i])))
#         if a == nothing no_nothing += 1 end
#         if a == false no_false += 1 end
#     end
#     if no_false > 0
#         return false
#     elseif no_nothing > 0
#         return nothing
#     else
#         return true
#     end
# end



# upper_triangular(M::Array{T,2}) where {T <: SymPyPythonCall.Sym} = SymPyPythonCall.istriu(M)
# lower_triangular(M::Array{T,2}) where {T <: SymPyPythonCall.Sym} = SymPyPythonCall.istril(M)
# diagonal(M::Array{T,2}) where {T <: SymPyPythonCall.Sym} = upper_triangular(M) && lower_triangular(M)
# triangular(M::Array{T,2}) where {T <: SymPyPythonCall.Sym} = upper_triangular(M) || lower_triangular(M)

# ## This is likely not the best way as it is a bit fidgety due
# ## to the call to rref.
# function full_rank(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     m,n = size(M)
#     m <= n || return full_rank(transpose(M))


#     rr, p = SymPyPythonCall.rref(M)
#     lr = rr[end, :] # is this zero?
#     no_nothing = 0
#     no_nonzero = 0
#     for val in lr
#         a = SymPyPythonCall.ask(nonzero(val))
#         if a == nothing
#             no_nothing += 1
#         end
#         if a == true
#             no_nonzero += 1
#         end
#     end
#     if no_nothing > 0
#         return nothing
#     elseif no_nonzero == 0
#         return false
#     else
#         return true
#     end

# end


# function square(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     m,n = SymPyPythonCall.size(M)
#     m == n
# end


# function real_elements(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     vals = real.(M)
#     for val in vals
#         a = SymPyPythonCall.ask(real(val))
#         (a == nothing || a == false) && return false
#     end
#     return true
# end


# function complex_elements(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     vals = real.(M)
#     for val in vals
#         a = SymPyPythonCall.ask(SymPyPythonCall.sympy."Q".complex(val))
#         (a == nothing || a == false) && return false
#     end
#     return true

# end


# function integer_elements(M::Array{T,2}) where {T <: SymPyPythonCall.Sym}
#     vals = real.(M)
#     for val in vals
#         a = SymPyPythonCall.ask(integer(val))
#         (a == nothing || a == false) && return false
#     end
#     return true
# end





# end

# ## Issue  #354; request to *not*  export  Q
# ## export
# #export Q

# const 𝑄 = Q

# """
#     𝑄

# Exported  symbol for  [`SymPy.Q`](@ref), a  Julia  module implementing `sympy.Q`. "Questions" can be asked through the patterns
# `𝑄.query(value)` (𝑄 is entered as  [slash]itQ[tab]) or `SymPy.Q.query(value)` *but  not* as `sympy.Q.query(value)`

# !!! note
#     At one time, the symbol `Q` was exported for this. To avoid namespace clutter, the unicode alternative is now used. Legacy code would need a definition like `const Q = SymPy.Q`  to work.

# """
# 𝑄
# export  𝑄
