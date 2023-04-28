# Wojciech Sęk 
#import Pkg 
#Pkg.add("Cbc")

using JuMP
using Cbc

# the width of a standard plank
std_width = parse(Int, readline())
# sizes of smaller planks
sizes  = [parse(Int, x) for x in split(readline())]
# demand for each size
demand = [parse(Int, x) for x in split(readline())]

# n = number of different sizes 
n = length(sizes)

function add_size(all_poss, j, size)
    new_arr = copy(all_poss)
    for i in eachindex(all_poss) 
        poss = all_poss[i]
        max_to_add = poss[n + 1] ÷ size 
        for k in 1:max_to_add 
            new_poss = copy(poss)
            new_poss[j] += k
            new_poss[n + 1] -= k * size
            push!(new_arr, new_poss)
        end
    end 

    return new_arr
end

function generate_possible()
    # current redundant wood width is kept at n + 1 idx
    start_poss = zeros(Int, n + 1)
    start_poss[n + 1] = std_width

    all_poss = [start_poss]

    for j in eachindex(sizes) 
        size = sizes[j]
        all_poss = add_size(all_poss, j, size)
    end

    return all_poss
end

all_methods  = generate_possible()

m = length(all_methods)

model = Model(Cbc.Optimizer)

# x_i - number of standard planks to be cut with i-th method 
@variable(model, x[1:m] >= 0, Int)
# there must be exactly demand[i] planks of length sizes[i] produced
@constraint(model, [i in 1:n], sum(x[j] * all_methods[j][i] for j in 1:m) == demand[i])
# the objective is to minimize quanitity of production leftovers
@objective(model, Min, sum(x[i] * all_methods[i][n + 1] for i in 1:m))

optimize!(model)

leftovers = objective_value(model)
println("leftovers = $leftovers")

x = value.(x)

for i in eachindex(x) 
    len = x[i]
    if len > 0
        println("$(x[i]) times take the partition into:")
        for j in eachindex(sizes) 
            println("   $(all_methods[i][j]) of length $(sizes[j])")
        end
    end 
end