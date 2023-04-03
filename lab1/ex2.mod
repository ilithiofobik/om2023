# Wojciech Sęk

set Cities;
set Types;

param multiplier{Types} >= 0;
param distance{Cities, Cities} >= 0;
param surplus{Cities, Types} >= 0;
param shortage{Cities, Types} >= 0;
param replacable_by{Types, Types} binary;

# ile dźwigów z miasta m1 do miasta m2, by zastąpić dźwigami typu t1 dźwigi typu t2
var transport{Cities, Cities, Types, Types} >=0 integer;

minimize transport_cost: sum{a in Cities, b in Cities, u in Types, v in Types} transport[a,b,u,v] * distance[a,b] * multiplier[u];

# nie można zastępować nieodpowiednimi dźwigami
s.t. no_illegal_replace{a in Cities, b in Cities, u in Types, v in Types: replacable_by[u,v] = 0} : transport[a,b,v,u] = 0;
# wysyłamy tyle dźwigów ile mamy nadmiaru
s.t. out_condition {a in Cities, u in Types} : sum{b in Cities, v in Types} transport[a,b,u,v] = surplus[a,u];
# odbieramy tyle dźwigów ile mamy niedoboru
s.t. in_condition  {a in Cities, u in Types} : sum{b in Cities, v in Types} transport[b,a,v,u] = shortage[a,u];

solve;

printf{a in Cities, b in Cities, u in Types, v in Types : transport[a,b,u,v] > 0}: 
    "\\item Przeniesc z %s do %s %d dzwigow typu %s w celu zastapienia typu %s.\n", a, b, transport[a,b,u,v], u, v;

display transport_cost;

end;

end;
