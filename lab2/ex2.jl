# Wojciech Sęk 

using JuMP
using Cbc

# task j takes p[j] time units to complete
p = [parse(Int, x) for x in split(readline())]
# task j has importance w[j]
w = [parse(Float64, x) for x in split(readline())]
# task j must start after r[j] time units at the earliest
r = [parse(Int, x) for x in split(readline())]
# time horizon
T = maximum(r) + sum(p) + 1

n = length(p)

model = Model(Cbc.Optimizer)

# x[i,j] = 1 if job i starts at time j
@variable(model, x[1:n, 1:T], Bin) 

# each task is executed exactly once
@constraint(model, [j in 1:n], sum(x[j,t] for t in 1:T) == 1)
# each task is executed after its release date
@constraint(model, [j in 1:n], sum((t-1) * x[j,t] for t in 1:T - p[j] + 1) >= r[j])
# tasks do not overlap
@constraint(model, [t in 1:T], sum(x[j,s] for j in 1:n, s in t:min(T, t-1+p[j])) <= 1)

# minimize weighted sum of completion times
@objective(model, Min, sum(w[j] * (t-1+p[j]) * x[j,t] for  j in 1:n, t in 1:T)) 

optimize!(model)		

println("Solution: ")
for j in 1:n
    for t in 1:T
        if value(x[j,t]) > 0.5
            println("Job ", j, " starts at ", t - 1)
        end
    end
end