# Wojciech Sęk

var b1 >= 0;
var b2 >= 0;

var b1_benzyna >= 0;
var b2_benzyna >= 0;

var b1_olej >= 0;
var b2_olej >= 0;

var b1_destylat >= 0;
var b2_destylat >= 0;

var b1_resztki >= 0;
var b2_resztki >= 0;

var b1_olej_dom >= 0;
var b2_olej_dom >= 0;

var b1_olej_ciez >= 0;
var b2_olej_ciez >= 0;

var b1_destylat_krak >= 0;
var b2_destylat_krak >= 0;

var b1_destylat_ciez >= 0;
var b2_destylat_ciez >= 0;

var krak >= 0;

var krak_benzyna >= 0;
var krak_olej    >= 0;
var krak_resztki >= 0;

var krak_b1_olej >= 0;
var krak_b2_olej >= 0;

var pal_sil >= 200000;
var dom_pal_olej >= 400000;
var ciez_pal_olej >= 250000;

minimize total_cost: 1300 * b1 + 1500 * b2 + 10 * (b1 + b2) + 20 * (b1_destylat_krak + b2_destylat_krak);

s.t. b1_benzyna_warunek  : b1_benzyna  = 0.15 * b1;
s.t. b1_olej_warunek     : b1_olej     = 0.40 * b1;
s.t. b1_destylat_warunek : b1_destylat = 0.15 * b1;
s.t. b1_resztki_warunek  : b1_resztki  = 0.15 * b1;
s.t. b2_benzyna_warunek  : b2_benzyna  = 0.10 * b2;
s.t. b2_olej_warunek     : b2_olej     = 0.35 * b2;
s.t. b2_destylat_warunek : b2_destylat = 0.20 * b2;
s.t. b2_resztki_warunek  : b2_resztki  = 0.25 * b2;

s.t. b1_olej_suma_warunek : b1_olej_ciez + b1_olej_dom = b1_olej;
s.t. b2_olej_suma_warunek : b2_olej_ciez + b2_olej_dom = b2_olej;

s.t. b1_destylat_suma_warunek : b1_destylat_ciez + b1_destylat_krak = b1_destylat;
s.t. b2_destylat_suma_warunek : b2_destylat_ciez + b2_destylat_krak = b2_destylat;

s.t. krak_warunek : b1_destylat_krak + b2_destylat_krak = krak;
s.t. krak_benzyna_warunek : krak_benzyna = 0.50 * krak;
s.t. krak_olej_warunek    : krak_olej    = 0.20 * krak;
s.t. krak_resztki_warunek : krak_resztki = 0.06 * krak;

s.t. krak_b1_olej_warunek : krak_b1_olej = 0.20 * b1_destylat_krak;
s.t. krak_b2_olej_warunek : krak_b2_olej = 0.20 * b2_destylat_krak;

s.t. pal_sil_suma:       b1_benzyna + b2_benzyna + krak_benzyna = pal_sil;
s.t. dom_pal_olej_suma:  b1_olej_dom + b2_olej_dom + krak_olej = dom_pal_olej;
s.t. ciez_pal_olej_suma: b1_olej_ciez + b2_olej_ciez + b1_resztki + b2_resztki + krak_resztki + b1_destylat_ciez + b2_destylat_ciez = ciez_pal_olej;

# siarka
s.t. siarka_warunek : dom_pal_olej * 0.005 >= (0.002 * b1_olej_dom) + (0.012 * b2_olej_dom) + (0.003 * krak_b1_olej) + (0.025 * krak_b2_olej);    

solve;

printf "b1 = %f ton\n", b1;
printf "b2 = %f ton\n", b2;

end;
