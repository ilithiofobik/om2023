# Wojciech Sęk 

using JuMP
using Cbc

# num of tasks
n = parse(Int, readline())
# num of machines
m = parse(Int, readline())
# predecessor 
pred = []
for i in 1:n
    push!(pred, [])
    line = [parse(Int, x) for x in split(readline())]
    for j in 1:n
        if line[j] == 1
            push!(pred[i], j)
        end
    end
end
# task j takes p[j] time units to complete
p = [parse(Int, x) for x in split(readline())]
# time horizon
T = sum(p) + 1

model = Model(Cbc.Optimizer)

# x[i,j,k] = 1 if job i starts at time j in machine k 
@variable(model, x[1:n, 1:T, 1:m], Bin) 
# max completion time
@variable(model, max_C, Int)
# max_C is max of completion times
@constraint(model, [j in 1:n, t in 1:T, k in 1:m], max_C >= (t-1+p[j]) * x[j,t,k])
# each task is executed exactly once on exactly one machine
@constraint(model, [j in 1:n], sum(x[j,t,k] for t in 1:T, k in 1:m) == 1)
# the preceding condition must be satisfied
@constraint(model, [b in 1:n, a in pred[b]], 
    sum((t+p[a]-1) * x[a,t,k] for t in 1:T - p[a] + 1, k in 1:m) <= 
    sum((t-1) * x[b,t,k] for t in 1:T - p[b] + 1, k in 1:m)
    )
# tasks do not overlap on given machine
@constraint(model, [t in 1:T, k in 1:m], sum(x[j,s,k] for j in 1:n, s in max(1, t+1-p[j]):t) <= 1)

# minimize weighted sum of completion times
@objective(model, Min, max_C) 

optimize!(model)		

println("Solution: ")
for k in 1:m
    print("M", k, ":")
    t = 1
    while t <= value.(max_C)
        is_used = false 
        for j in 1:n
            if value(x[j,t,k]) > 0.5
                for _ in 1:p[j] 
                    print(" ", j)
                end
                t += p[j]
                is_used = true
                break
            end
        end
        if !is_used
            print(" _")
            t += 1
        end
    end
    println()
end