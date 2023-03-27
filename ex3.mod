set Cities;
set Types;

param multiplier{Types} >= 0;
param distance{Cities, Cities} >= 0;
param surplus{Cities, Types} >= 0;
param shortage{Cities, Types} >= 0;
param replacable{Types} binary;

var transport{Cities, Cities, Types} >=0 integer;

minimize transport_cost: sum{a in Cities, b in Cities, t in Types} transport[a,b,t] * distance[a,b] * multiplier[t];

#s.t. no_inner_transport{a in Cities, t in Types}:  transport[a,a,t] = 0;
s.t. out_condition {a in Cities, t in Types} : sum{b in Cities}  transport[a,b,t] = surplus[a,t];
s.t. in_condition  {a in Cities, t in Types} : sum{b in Cities, y in Types}  transport[b,a,y] = sum{y in Types} shortage[a,y];

s.t. replacable_condition {a in Cities, t in Types : replacable[t] = 0} : sum{b in Cities} transport[b,a,t] >= shortage[a,t];

solve;

printf{t in Types, a in Cities, b in Cities : transport[a,b,t] > 0}: 
    "(%s -> %s: type %s) %d\n", a, b, t, transport[a,b,t];

end;

end;
