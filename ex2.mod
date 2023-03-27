set Cities;
set Types;

param multiplier{Types} >= 0;
param distance{Cities, Cities} >= 0;
param surplus{Cities, Types} >= 0;
param shortage{Cities, Types} >= 0;
# read as t1 can be replaced by t2
param replacable_by{Types, Types} binary;

# transport from city to city, type1 to replace type2
var transport{Cities, Cities, Types, Types} >=0 integer;

minimize transport_cost: sum{a in Cities, b in Cities, t1 in Types, t2 in Types} transport[a,b,t1,t2] * distance[a,b] * multiplier[t1];

#s.t. no_inner_transport{a in Cities, t in Types}:  transport[a,a,t] = 0;
s.t. no_illegal_replace{a in Cities, b in Cities, t1 in Types, t2 in Types: replacable_by[t1,t2] = 0} : transport[a,b,t2,t1] = 0;
s.t. out_condition {a in Cities, t1 in Types} : sum{b in Cities, t2 in Types} transport[a,b,t1,t2] = surplus[a,t1];
s.t. in_condition  {a in Cities, t1 in Types} : sum{b in Cities, t2 in Types} transport[b,a,t2,t1] = shortage[a,t1];

solve;

printf{t1 in Types, t2 in Types, a in Cities, b in Cities : transport[a,b,t1,t2] > 0}: 
    "(%s -> %s: %s replacing %s) %d\n", a, b, t1, t2, transport[a,b,t1,t2];

end;

end;
