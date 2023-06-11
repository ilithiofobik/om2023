# Wojciech Sęk

using JuMP
using GLPK

function read_p(fname)
    f=open(fname)
    lines = readlines(f)
    close(f)

    sizes = split(lines[1])
    n = parse(Int, sizes[1])
    m = parse(Int, sizes[2])
    p = zeros(Int, m, n)

    for (j,line) in enumerate(lines[3:end])
        columns = split(line)
        columns = columns[2:2:end]
        for (i, val) in enumerate(columns)
            p[i, j] = parse(Int, val)
        end
    end

    return p
end

function calc_alpha(p)
    (m, n) = size(p)
    ts = zeros(Int, m)
    for j in 1:n
        min_val, min_idx = findmin(p[:, j])
        ts[min_idx] += min_val
    end
    return maximum(ts)
end

function is_feasible(p, T)
    (m, n) = size(p)

    S_not_T = [(i, j) for i in 1:m, j in 1:n if p[i,j] > T] 
    S_T_j = [[i for i in 1:m if p[i,j] <= T] for j in 1:n] # maszyny że <= T dla zadania j 
    S_T_i = [[j for j in 1:n if p[i,j] <= T] for i in 1:m] # zadania że <= T na maszynie i
    
    model = Model(GLPK.Optimizer)
    # x[i,j] -> 1 gdy zadanie i jest wykonywane na maszynie j
    @variable(model, x[1:m, 1:n] >= 0) 
    # maszyny nie mogą wykonywać zadania w czasie > T
    @constraint(model, [(i,j) in S_not_T], x[i,j] == 0)
    # jedno zadanie jest wykonywane na dokładnie jednej maszynie
    @constraint(model, [j in 1:n], sum(x[i,j] for i in S_T_j[j]) == 1)
    # sumaryczny czas wykonywania zadań na maszynie nie może przekroczyć T
    @constraint(model, [i in 1:m], sum(x[i,j] * p[i,j] for j in S_T_i[i]) <= T)
    set_silent(model)
    optimize!(model)

    if termination_status(model) == OPTIMAL::TerminationStatusCode
        return true, value.(x)
    else 
        return false, nothing
    end
end 

function find_min_T(p)
    alpha = calc_alpha(p)
    (m, _) = size(p)
    right = alpha 
    left  = alpha ÷ m

    while left <= right
        mid = (left + right) ÷ 2
        is_ok, _ = is_feasible(p, mid)
        if is_ok
            right = mid - 1
        else
            left = mid + 1
        end
    end

    T = left
    _, x = is_feasible(p, T)
    
    return T, x
end

function refine_x(x, n, m)
    # cięcie liści
    for i in 1:m
        if count(x -> 0 < x && x < 1, x[i, 1:n]) == 1
            j = findfirst(x -> 0 < x && x < 1, x[i, 1:n])
            for k in 1:m
                x[k, j] = 0
            end
            x[i, j] = 1
        end
    end

    # cięcie cykli
    for j in 1:n 
        for i in 1:m
            if 0 < x[i, j] && x[i, j] < 1
                for k in 1:m
                    x[k, j] = 0
                end
                x[i, j] = 1
            end
        end
    end

    return x
end

function find_makespan(fname)
    p = read_p(fname)
    (m, n) = size(p)
    _, x = find_min_T(p)
    x = refine_x(x, n, m)
    return maximum([sum(p[i, j] * x[i, j] for j in 1:n) for i in 1:m])
end

instances_name = "Instanciasde1000a1100"
dir_name_len = length(instances_name)
instances = readdir(instances_name, join = true)

for instance in instances
    name = instance[dir_name_len + 2 : end - 4]
    makespan = find_makespan(instance)
    println(name, ';', Int(round(makespan)))
end