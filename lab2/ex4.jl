# Wojciech Sęk 

using JuMP
using Cbc

# num of resources
p = parse(Int, readline()) # i
# amount of resources
N = [parse(Int, x) for x in split(readline())] 
# num of tasks 
n = parse(Int, readline()) # j
# time to complete tasks
t = [parse(Int, x) for x in split(readline())]
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
# demand for resources
r = []
for i in 1:n
    push!(r, [parse(Int, x) for x in split(readline())])
end
# time horizon
T = sum(t) + 1

model = Model(Cbc.Optimizer)

# x[i,j] = 1 if job i starts at time j 
@variable(model, x[1:n, 1:T], Bin) 
# max completion time
@variable(model, max_C, Int)
# max_C is max of completion times
@constraint(model, [j in 1:n, ti in 1:T], max_C >= ((ti - 1) * x[j, ti] + t[j]))
# each task is executed exactly once
@constraint(model, [j in 1:n], sum(x[j,ti] for ti in 1:T) == 1)
# the preceding condition must be satisfied
@constraint(model, [b in 1:n, a in pred[b]], 
    sum((ti+t[a]-1) * x[a,ti] for ti in 1:T - t[a] + 1) <= 
    sum((ti-1) * x[b,ti] for ti in 1:T - t[b] + 1)
    )
# tasks do not overceed resource capacity
@constraint(model, [ti in 1:T, i in 1:p], sum(x[j,s] * r[j][i] for j in 1:n, s in max(1, ti+1-t[j]):ti) <= N[i])

# minimize weighted sum of completion times
@objective(model, Min, max_C) 

optimize!(model)		

println("Solution: Total Time = ", value.(max_C))
for j in 1:n
    print("t", j, ": ")
    ti = 1
    while ti <= value.(max_C)
        if value(x[j,ti]) > 0.5
            for _ in 1:t[j] 
                print("*")
            end
            ti += t[j]
            for _ in ti:value.(max_C) 
                print("_")
            end
            break
        else 
            print("_")
            ti += 1
        end
    end
    println()
end

for i in 1:p 
    print("r", i, ":")
    for ti in 1:T 
        usage = 0
        for j in 1:n 
            for s in max(1, ti+1-t[j]):ti
                usage += value.(x[j,s]) * r[j][i] 
            end 
        end
        println(" ", usage)
    end 
    println()
end 