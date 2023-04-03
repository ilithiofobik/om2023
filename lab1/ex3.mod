# Wojciech Sęk

set Crude;
set CrudeProds;
set OilUsage;
set DistillateProds;
set DistillateUsage;

param crude_cost {Crude}                 >= 0;
param efficiency {CrudeProds, Crude}     >= 0;
param crack_efficiency {DistillateProds} >= 0;

param distillate_cost >= 0;
param cracking_cost   >= 0;

param min_petrol    >= 0;
param min_civil_oil >= 0;
param min_heavy_oil >= 0;

param sulphur_limit >= 0;

param distillate_oil_sulphur{Crude} >= 0;
param crack_oil_sulphur{Crude}      >= 0;

var amount {Crude}                      >= 0;
var oil {OilUsage, Crude}               >= 0;
var distillate {DistillateUsage, Crude} >= 0;

minimize total_cost: sum {c in Crude} ((crude_cost[c] + distillate_cost) * amount[c] + cracking_cost * distillate["crack", c]);

s.t. oil_suma_warunek{c in Crude}        : efficiency["oil", c]        * amount[c] = sum {o in OilUsage} oil[o, c];
s.t. distillate_suma_warunek{c in Crude} : efficiency["distillate", c] * amount[c] = sum {d in DistillateUsage} distillate[d, c];

s.t. pal_sil_suma:       min_petrol    <= sum {c in Crude} (crack_efficiency["petrol"] *  distillate["crack", c] + efficiency["petrol", c] * amount[c]);
s.t. civil_pal_oil_suma: min_civil_oil <= sum {c in Crude} (crack_efficiency["oil"] * distillate["crack", c] + oil["civil", c]);
s.t. heavy_pal_oil_suma: min_heavy_oil <= sum {c in Crude} (oil["heavy", c] + distillate["heavy", c] + efficiency["remnant", c] * amount[c] + crack_efficiency["remnant"] * distillate["crack", c]);

s.t. sulphur_cond : 
    sulphur_limit * sum {c in Crude} (crack_efficiency["oil"] * distillate["crack", c] + oil["civil", c]) >= 
    sum {c in Crude} (distillate_oil_sulphur[c] * oil["civil", c] + (crack_oil_sulphur[c] * crack_efficiency["oil"] * distillate["crack", c]));    

solve;

display amount;
display oil;
display distillate;
display total_cost;

end;
