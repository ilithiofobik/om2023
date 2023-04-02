# Wojciech Sęk

set Courses;
set Groups;

param StartingTime {Groups, Courses} >= 0;
param EndingTime   {Groups, Courses} >= 0;
param Day          {Groups, Courses} >= 0 integer;
param Preference   {Groups, Courses} >= 0 integer;

set PEGroups;

param PEStartingTime {PEGroups} >= 0;
param PEEndingTime   {PEGroups} >= 0;
param PEDay          {PEGroups} >= 0 integer;

var x {Groups, Courses} binary;
var y {PEGroups} binary;

maximize total_preference: sum {g in Groups, c in Courses} Preference[g,c] * x[g,c];

s.t. no_lessons_on_wednesday   {g in Groups, c in Courses : Day[g,c] = 3} : x[g,c] = 0;
s.t. no_lessons_on_friday      {g in Groups, c in Courses : Day[g,c] = 5} : x[g,c] = 0;
s.t. no_preference_less_that_5 {g in Groups, c in Courses : Preference[g,c] <= 4 } : x[g,c] = 0;

s.t. max_day_length {d in 1..5} : 
    sum {g in Groups, c in Courses : Day[g,c] = d} (EndingTime[g,c] - StartingTime[g,c]) * x[g,c] <= 4;

s.t. one_group_per_course {c in Courses} : 
    sum {g in Groups} x[g,c] = 1;

s.t. no_overlap {g1 in Groups, g2 in Groups, c1 in Courses, c2 in Courses : 
    (c1 != c2 or g1 != g2) and 
    Day[g1,c1] = Day[g2,c2] and 
    StartingTime[g1, c1] <= StartingTime[g2, c2]  and 
    StartingTime[g2, c2] <= EndingTime[g1, c1] } : 
        x[g1,c1] + x[g2,c2] <= 1;

s.t. no_PE_overlap {g1 in Groups, c1 in Courses, p in PEGroups : 
    Day[g1,c1] = PEDay[p] and 
    StartingTime[g1, c1] <= PEStartingTime[p]  and 
    PEStartingTime[p] <= EndingTime[g1, c1] } : 
        x[g1,c1] + y[p] <= 1;

s.t. lunch_break {d in 1..5} : 
    (sum {g in Groups, c in Courses : Day[g,c] = d and StartingTime[g,c] <   12 and EndingTime[g,c] <= 14} (EndingTime[g,c] - 12)                 * x[g,c]) + 
    (sum {g in Groups, c in Courses : Day[g,c] = d and StartingTime[g,c] >=  12 and EndingTime[g,c] <= 14} (EndingTime[g,c]  - StartingTime[g,c]) * x[g,c]) + 
    (sum {g in Groups, c in Courses : Day[g,c] = d and StartingTime[g,c] >=  12 and EndingTime[g,c] >  14} (14 - StartingTime[g,c])               * x[g,c]) +
    (sum {p in PEGroups             : PEDay[p] = d and PEStartingTime[p] <   12 and PEEndingTime[p] <= 14} (PEEndingTime[p] - 12)                 * y[p])   + 
    (sum {p in PEGroups             : PEDay[p] = d and PEStartingTime[p] >=  12 and PEEndingTime[p] <= 14} (PEEndingTime[p]  - PEStartingTime[p]) * y[p])   + 
    (sum {p in PEGroups             : PEDay[p] = d and PEStartingTime[p] >=  12 and PEEndingTime[p] >  14} (14 - PEStartingTime[p])               * y[p])   <= 1;

s.t. min_on_training : sum {g in PEGroups} y[g] >= 1;

solve;

printf "Total preference: %d\n", total_preference;
printf{g in Groups, c in Courses : x[g,c] > 0}: 
    "Take course %s with group %s\n", c, g;
printf{p in PEGroups: y[p] = 1}: 
    "Train on day %d between %d and %d\n", PEDay[p], PEStartingTime[p], PEEndingTime[p];

end;
