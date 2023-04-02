# Wojciech Sęk

set Crude;
set CrudeProds;
set OilUsage;
set Prods;
set DestylatCel;

param crude_cost {Crude}               >= 0;
param efficiency {CrudeProds, Crude}   >= 0;
param crack_efficiency {Prods} >= 0;
param destillation_cost >= 0;
param cracking_cost     >= 0;

param min_pal_sil       >= 0;
param min_dom_pal_oil  >= 0;
param min_ciez_pal_oil >= 0;

param sulfur_limit >= 0;
param destill_oil_sulfur{Crude} >= 0;
param crack_oil_sulfur{Crude}   >= 0;

var amount {Crude}                  >= 0;
var oil {OilUsage, Crude}     >= 0;
var distillate {DestylatCel, Crude} >= 0;

minimize total_cost: sum {r in Crude} ((crude_cost[r] + destillation_cost) * amount[r] + cracking_cost * distillate["crack", r]);

s.t. oil_suma_warunek{r in Crude}     : efficiency["oil", r]     * amount[r] = sum {o in OilUsage} oil[o, r];
s.t. destylat_suma_warunek{r in Crude} : efficiency["destylat", r] * amount[r] = sum {d in DestylatCel} distillate[d, r];

s.t. pal_sil_suma:       min_pal_sil       <= sum {r in Crude} (crack_efficiency["petrol"] *  distillate["crack", r] + efficiency["petrol", r] * amount[r]);
s.t. dom_pal_oil_suma:  min_dom_pal_oil  <= sum {r in Crude} (crack_efficiency["oil"] * distillate["crack", r] + oil["domowe", r]);
s.t. ciez_pal_oil_suma: min_ciez_pal_oil <= sum {r in Crude} (oil["ciezkie", r] + distillate["ciezkie", r] + efficiency["resztki", r] * amount[r] + crack_efficiency["resztki"] * distillate["crack", r]);

s.t. sulfur_cond : 
    sulfur_limit * sum {r in Crude} (crack_efficiency["oil"] * distillate["crack", r] + oil["domowe", r]) >= 
    sum {r in Crude} (destill_oil_sulfur[r] * oil["domowe", r] + (destill_oil_sulfur[r] * crack_efficiency["oil"] * distillate["crack", r]));    

solve;

display amount;
display oil;
display distillate;
display total_cost;

end;
