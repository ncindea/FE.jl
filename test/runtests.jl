using FEMTools
using Base.Test

# Testing Lagrange elements
println("# Testing Lagrange elements")
p1 = FEMTools.get_lagrange_basis()
@test SymPy.degree(p1[1], gen=FEMTools.x) == 1
@test SymPy.degree(p1[2], gen=FEMTools.x) == 1
@test SymPy.subs(p1[1], FEMTools.x, 0) == 1
@test SymPy.subs(p1[1], FEMTools.x, FEMTools.h) == 0
@test SymPy.subs(p1[2], FEMTools.x, FEMTools.h) == 1
@test SymPy.subs(p1[2], FEMTools.x, 0) == 0

p4 = FEMTools.get_lagrange_basis(4)
E = eye(5, 5)
for i = 1:4
  @test SymPy.degree(p4[i], gen=FEMTools.x) == 4
  for j = 1:5
      @test SymPy.subs(p4[i], FEMTools.x, (j - 1) * FEMTools.h / 4) == E[i, j]
  end
end

M = FEMTools.get_lagange_em()
@test (M[1, 1] == FEMTools.h / 3) && ((M[1, 2] == FEMTools.h / 6)) &&
      (M[2, 1] == FEMTools.h / 6) && ((M[2, 2] == FEMTools.h / 3))

MVC = FEMTools.get_lagrange_em_varcoeff()
MVC = SymPy.subs(MVC, FEMTools.xa, 0)
MVC = SymPy.subs(MVC, FEMTools.xb, FEMTools.h)
@test (MVC[1, 1] == FEMTools.h / 3) && (MVC[1, 2] == FEMTools.h / 6) &&
      (MVC[2, 1] == FEMTools.h / 6) && (MVC[2, 2] == FEMTools.h / 3)

# Testing Hermite elements
println("# Testing Hermite elements")
p3 = FEMTools.get_hermite_basis()
@test SymPy.subs(p3[1], FEMTools.x, 0) == 1
@test SymPy.subs(p3[1], FEMTools.x, FEMTools.h) == 0
@test SymPy.subs(SymPy.diff(p3[1], FEMTools.x), FEMTools.x, 0) == 0
@test SymPy.subs(SymPy.diff(p3[1], FEMTools.x), FEMTools.x, FEMTools.h) == 0

@test SymPy.subs(p3[2], FEMTools.x, 0) == 0
@test SymPy.subs(p3[2], FEMTools.x, FEMTools.h) == 0
@test SymPy.subs(SymPy.diff(p3[2], FEMTools.x), FEMTools.x, 0) == 1
@test SymPy.subs(SymPy.diff(p3[2], FEMTools.x), FEMTools.x, FEMTools.h) == 0

@test SymPy.subs(p3[3], FEMTools.x, 0) == 0
@test SymPy.subs(p3[3], FEMTools.x, FEMTools.h) == 1
@test SymPy.subs(SymPy.diff(p3[3], FEMTools.x), FEMTools.x, 0) == 0
@test SymPy.subs(SymPy.diff(p3[3], FEMTools.x), FEMTools.x, FEMTools.h) == 0

@test SymPy.subs(p3[4], FEMTools.x, 0) == 0
@test SymPy.subs(p3[4], FEMTools.x, FEMTools.h) == 0
@test SymPy.subs(SymPy.diff(p3[4], FEMTools.x), FEMTools.x, 0) == 0
@test SymPy.subs(SymPy.diff(p3[4], FEMTools.x), FEMTools.x, FEMTools.h) == 1

MH = FEMTools.get_hermite_em()
h = FEMTools.h
MH_hc = [13*h/35 11*h^2/210 9*h/70 -13*h^2/420;
         11*h^2/210 h^3/105 13*h^2/420 -h^3/140;
         9*h/70 13*h^2/420 13*h/35 -11*h^2/210;
         -13*h^2/420 -h^3/140 -11*h^2/210 h^3/105]
@test MH == MH_hc

MHVC = FEMTools.get_hermite_em_varcoeff()
MHVC = SymPy.subs(MHVC, FEMTools.xa, 0)
MHVC = SymPy.subs(MHVC, FEMTools.xb, FEMTools.h)
@test MHVC == MH_hc

try
  FEMTools.get_hermite_basis(2)
catch y
  println(y)
end

##
t = linspace(0, 1, 11)'
ti = linspace(0, 1, 101)'
x = sin(pi * t)
y = pi * cos(pi * t)
fdf = [x; y]
f = FEMTools.interpolate(fdf, t, ti)
@test norm(f[1:10:101]' - x) <= 1e-15

## Testing get_em() function.
println("Testing get_em() function.")
@test FEMTools.get_em(1, 1, 0, 0) == FEMTools.get_lagange_em(1, 0, 0)
@test FEMTools.get_em(3, 3, 1, 0; fe1 = "Hermite", fe2 = "Hermite") == FEMTools.get_hermite_em(3, 1, 0)
try
  FEMTools.get_em(1, 1, 0, 0; fe1 = "a", fe2 = "Lagrange")
catch y
  println(y)
end

try
  FEMTools.get_em(1, 1, 2, 0)
catch y
  println(y)
end

try
  FEMTools.get_em(1, 1, 1, 2)
catch y
  println(y)
end

try
  FEMTools.get_em(3, 3, 3, 0; fe1 = "Hermite", fe2="Hermite")
catch y
  println(y)
end

try
  FEMTools.get_em(3, 3, 2, -1; fe1 = "Hermite", fe2="Hermite")
catch y
  println(y)
end

##
n = 1001
x = linspace(0, 1, 2 * n - 1).^2
dx = 1 / (n - 1)

elem_M = FEMTools.get_lagange_em(2, 0, 0)
elem_M = SymPy.subs(elem_M, FEMTools.h, dx)
elem_M = convert(Matrix{Float64}, elem_M)
M = FEMTools.assemble_1d_FE_matrix(elem_M, n, intNodes = 1, dof1 = 1, dof2 = 1)
@test abs(convert(Float64, (x' * M * x)[1]) - 1 / 5) < 1e-15

elem_M_p1 = FEMTools.get_lagange_em(1, 0, 0)
elem_M_p1 = SymPy.subs(elem_M_p1, FEMTools.h, dx)
elem_M_p1 = convert(Matrix{Float64}, elem_M_p1)
M_p1 = FEMTools.assemble_1d_FE_matrix(elem_M_p1, n)
x = linspace(0, 1, n).^2
@test abs(convert(Float64, (x' * M_p1 * x)[1]) - 1 / 5) < 1e-6

elem_M_h3 = FEMTools.get_hermite_em(3, 0, 0)
elem_M_h3 = SymPy.subs(elem_M_h3, FEMTools.h, dx)
elem_M_h3 = convert(Matrix{Float64}, elem_M_h3)
M_h3 = FEMTools.assemble_1d_FE_matrix(elem_M_h3, n, intNodes = 0, dof1 = 2, dof2 = 2)
x = zeros(2 * n, 1)
x[2*(0:(n-1)) + 1] = linspace(0, 1, n).^3
x[2*(0:(n-1)) + 2] = 3 * linspace(0, 1, n).^2
@test abs(convert(Float64, (x' * M_h3 * x)[1]) - 1 / 7) < 1e-15

nodes = convert(Array{Float64, 1}, linspace(0, 1, n))
elem_M_p1 = FEMTools.get_lagange_em(1, 0, 0)
M_p1_nu = FEMTools.assemble_1d_FE_matrix(elem_M_p1, nodes; intNodes = 0, dof1 = 1, dof2 = 1)
A = M_p1 - M_p1_nu
@test norm(A[:]) < 1e-15
##

nodes = [linspace(0, 0.99, 100); linspace(0.99, 1, 101)]
M_p1_nu2 = FEMTools.assemble_1d_FE_matrix(elem_M_p1, nodes; intNodes = 0, dof1 = 1, dof2 = 1)
x = nodes.^2
@test abs((x' * M_p1_nu2 * x)[1] - 1 / 5) < 1e-4
println("All tests passed.")
