set Courses;
set Groups;

param StartingTime {Groups, Courses} >= 0;
param EndingTime   {Groups, Courses} >= 0;
param Day          {Groups, Courses} >= 0 integer;
param Preference   {Groups, Courses} >= 0 integer;

var x {Groups, Courses} binary;

maximize total_preference: sum {g in Groups, c in Courses} Preference[g,c] * x[g,c];

s.t. no_lessons_on_wednesday   {g in Groups, c in Courses : Day[g,c] = 3} : x[g,c] = 0;
s.t. no_lessons_on_friday      {g in Groups, c in Courses : Day[g,c] = 5} : x[g,c] = 0;
s.t. no_preference_less_that_5 {g in Groups, c in Courses : Preference[g,c] <= 4 } : x[g,c] = 0;
#s.t. no_preference_less_that_5 {g in Groups, c in Courses } : Preference[g,c] * (1 - x[g,c]) <= 1110;

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

s.t. lunch_break {d in 1..5} : 
    (sum {g in Groups, c in Courses : Day[g,c] = d and StartingTime[g,c] <  12 and EndingTime[g,c] <= 14} (EndingTime[g,c] - 12)                 * x[g,c]) + 
    (sum {g in Groups, c in Courses : Day[g,c] = d and StartingTime[g,c] >= 12 and EndingTime[g,c] <= 14} (EndingTime[g,c]  - StartingTime[g,c]) * x[g,c]) + 
    (sum {g in Groups, c in Courses : Day[g,c] = d and StartingTime[g,c] >= 12 and EndingTime[g,c] >  14} (14 - StartingTime[g,c])               * x[g,c]) <= 1;

s.t. sport_break {g1 in Groups, g2 in Groups, g3 in Groups, c1 in Courses, c2 in Courses, c3 in Courses : 
    Day[g1,c1] = 1 and
    Day[g2,c2] = 3 and
    Day[g3,c3] = 3 and
    ((StartingTime[g1,c1] >=  13 and StartingTime[g1,c1] < 15) or (EndingTime[g1,c1] > 13 and EndingTime[g1,c1] <= 15)) and
    ((StartingTime[g2,c2] >=  11 and StartingTime[g2,c2] < 13) or (EndingTime[g2,c2] > 11 and EndingTime[g2,c2] <= 13)) and
    ((StartingTime[g3,c3] >=  13 and StartingTime[g3,c3] < 15) or (EndingTime[g3,c3] > 13 and EndingTime[g3,c3] <= 15)) } : 
        x[g1,c1] + x[g2,c2] + x[g3, c3] <= 2;

solve;

display x;

end;
