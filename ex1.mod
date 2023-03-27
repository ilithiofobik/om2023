param n >= 1;

param A{i in {1..n}, j in {1..n}} := 1/(i + j - 1);
param b{i in {1..n}} := sum{j in {1..n}}(1/(i + j -1));
param c{i in {1..n}} := b[i];

var x{i in {1..n}}, >=0;

minimize cost_func: sum{i in {1..n}} x[i] * c[i];

s.t. hilbert{i in 1..n}: sum{j in {1..n}} x[j] * A[i, j] = b[i];

solve;

printf "error %.20f\n",
    sqrt(sum{i in {1..n}} ((x[i] -  1) * (x[i] - 1)))/sqrt(n);