
; Import the CSV extension file for reading and writing
extensions [csv]

; Declaring the global variables for the model
globals [
  student_id         ; Unique ID for a student ex: 23106367
  student_name           ; Name of the particular student
  student_score         ; Achieved score by the student
  student_feedback          ; Provided feedback to the student

  most_effective_measure    ; Measure considered to be most effective
  least_effective_measure      ; Measure considered to be least effective
  population_with_highest_mortality_rate           ; Highest mortality rate Population group
  population_most_immune     ; Highest immunity based Population group.
  self_isolation_link       ; self-isolation measures Link or reference.
  population_density      ; Density of population

  total_infected_percentage     ; total infected population
  pink_infected_percentage     ; pink group that is infected
  gray_infected_percentage   ; gray group that is infected

  total_deaths    ; Total number of deaths in the simulation
  pink_deaths        ; number of deaths in the pink group
  gray_deaths  ; number of deaths in the gray group

  total_antibodies_percentage   ; population with antibodies (Percentage)
  pink_antibodies_percentage     ; pink group with antibodies (Percentage)
  gray_antibodies_percentage   ; gray group with antibodies (Percentage)
  stored_settings
]

; Define the properties specific to turtles (agents) in "23106367" student model
turtles-own [
  infected_time   ; Time duration for which the turtle has been infected
  antibodies      ; Total Number of antibodies present in the turtle
  group       ; Group classification for the turtle (e.g., pink or gray)
]



; Define a procedure to set up the world environment and initial model parameters
to setup_world
  reset-ticks     ; Resets the tick to zero counter

  ; Set student information
  set student_id "23106367" ; Assign my unique Student ID.
  set student_name "S M Mahamudul Hasan" ; Assign My name.

  ; Defining the pink and gray regions in the simulation space
  ask patches [
    if pycor >= 0 [ set pcolor pink ]  ; Set patches with the non-negative y-coordinate to pink
    if pycor < 0 [ set pcolor gray ]   ; Set patches with the negative y-coordinate to gray
  ]

  ; Initializing the default global variables for the simulation
  set pink_population 1500     ; Setting population size of the pink region to 1500
  set gray_population 1000   ; Setting population size of the gray region to 1000
  set initially_infected 15    ; Setting initial number of infected individuals to 15
  set infection_rate 30   ; Setting rate of infection spread to 30
  set survival_rate 60    ; Setting probability of surviving an infection to 60
  set immunity_duration 260    ; Setting the duration for which immunity lasts after recovery to 260
  set undetected_period 75   ; Setting duration of the undetected infection period to 75
  set illness_duration 290  ; Setting total duration of illness once infected to 290
  set travel_restrictions false  ; Setting Flag indicating whether travel restrictions value false
  set social_distancing false   ; Setting Flag indicating whether social distancing value false.
  set self_isolation false  ; Setting Flag indicating whether self-isolation value false.

  ; Initialize death counters for tracking mortality rates
  set total_deaths 0    ; primary total deaths counter to zero
  set pink_deaths 0    ; primary deaths in the pink population to zero
  set gray_deaths 0      ; primary deaths in the gray population to zero
end






; Define the set up agents process (turtles) in the simulation
to setup_agents
  ; Creating the pink population of turtles
  create-turtles pink_population [
    set color yellow      ; Setting up the turtle color to yellow for representing a healthy individual
    set size 3        ; Setting up the turtle size for making them visible on the screen
    setxy random-xcor random-ycor   ; Place each of the turtle at a random location

    ; Ensure the turtles are only one placed on pink patches
    while [pcolor != pink] [
      setxy random-xcor random-ycor  ; Reposition of the turtle if it is not on a pink patch
    ]
    set antibodies 0    ; Initialize antibody count to zero
    set group "pink turtle"    ; Assign the turtle to the "pink" group
  ]

  ; Create the gray population of turtles
  create-turtles gray_population [
    set color yellow      ; Setting turtle color yellow for healthy status
    set size 3        ; Setting the size of the turtle
    setxy random-xcor random-ycor   ; Placing each turtle at a random position

    ; Ensuring the turtles are only placed on gray patches
    while [pcolor != gray] [
      setxy random-xcor random-ycor ; Reposition of the turtle if it is not on a gray patch
    ]
    set antibodies 0    ; Initializing the antibody count to zero
    set group "gray turtle"  ; Assign the turtle to the "gray" group
  ]

  ; Infect a set number of initially infected individuals in the pink group
  ask n-of initially_infected turtles with [group = "pink turtle"] [
    set color green    ; Change color to green to indicate infection
    set infected_time illness_duration  ; Set the infection duration to the predefined illness duration
  ]

  ; Infect a set number of initially infected individuals in the gray group
  ask n-of initially_infected turtles with [group = "gray turtle"] [
    set color green     ; Change color to green to show infection status
    set infected_time illness_duration    ; Setting up the infection duration for the infected turtle
  ]
end




; Main function to run the model's behavior each tick
to run_model
  tick ; Increment the tick counter by 1

  ; Instruct all turtles to execute their individual behaviors
  ask turtles [
    move_turtle  ; Moving turtles depending on movement rules and parameters
    manage_infection ;Dealing with the infection spread and turtle states
  ]

  update_global_variables  ; Simultaniously update global metrics and statistics
end

; Function to manage individual turtle movement
to move_turtle
  ; Set random adjustments to heading within a 40-degree range to simulate natural movement
  set heading heading + random-float 40 - 20
  fd 0.3    ; Move turtle forward at speed 0.3 per tick

  ; Enforce travel restrictions if active, keeping turtles within their designated color region
  if travel_restrictions [
    if not (pcolor = color) [  ; Check if turtle is outside its assigned color region
      set heading towards (ifelse-value (color = pink) [patch 0 0] [patch 0 0]) ; Set heading to move back to correct region
    ]
  ]

  ; Implementing the social distancing: if enabled, turtles avoid each other within a radius of 1 patch
  if social_distancing [
    let nearby (turtles in-radius 1)   ; Detecting the nearby turtles within a radius of 1
    if (any? nearby) [    ; If another turtle is within the radius, change direction
;      set heading random 360
      set heading heading + random-float 40 - 20  ; Setiing heading added with random floating number.

    ]
  ]

  ; Managing self-isolation behavior: stop movement if infected and isolation is required
  if (self_isolation and infected_time <= undetected_period) [
    set color blue   ; Changing the turtle color to blue to indicate self-isolation
    set infected_time 0    ; Halt infection countdown
  ]
end



; Function to manage infection spread and infection countdown

to manage_infection
  ; Checking if turtle is currently infected
  if color = green [
    ; Countdown the infection duration
    set infected_time infected_time - 1

    ; Once infection time is up, determine survival outcome
    if infected_time <= 0 [
      if (random 100 < survival_rate) [ ; Survival check: chance of survival based on survival_rate
        set antibodies immunity_duration ; Granting the immunity for a set duration
        set color black  ; Changing the color to black to indicate immunity
      ]
      die  ; Turtle  dies if survival check fails
    ]
  ]

  ; Spreading the infection to nearby turtles
  ask turtles with [color = green] [   ; Only infected (green) turtles can spread the infection
    ask turtles in-radius 1 [
      if (color = yellow and random 100 < infection_rate) [ ; Infection occurs based on infection_rate probability
        set color green    ; Change to green to indicate infection
        set infected_time illness_duration  ; Initialize infection countdown
      ]
    ]
  ]
end


; Function for  updating the global variables that track infection, death, and immunity statistics
to update_global_variables

  ; Calculating the total population and infected percentage
  let total_population count turtles                     ; Total number of turtles
  let total_infected count turtles with [color = green]  ; Total number of infected turtles (green color) are shown.
  set total_infected_percentage (total_infected / total_population) * 100 ; Calculate overall infection percentage

  ; Calculating the pink population count and infected percentage within pink group
  let pink_population_count count turtles with [group = "pink turtle"] ; Total pink population
  let pink_infected count turtles with [group = "pink turtle" and color = green] ; Infected pink turtles
  set pink_infected_percentage (pink_infected / pink_population_count) * 100 ; Pink group infection percentage

  ; Calculating the gray population count and infected percentage within gray group
  let gray_population_count count turtles with [group = "gray turtle"] ; Total gray population
  let gray_infected count turtles with [group = "gray turtle" and color = green] ; Infected gray turtles
  set gray_infected_percentage (gray_infected / gray_population_count) * 100 ; Gray group infection percentage

  ; Updating the total death counts across populations
  set total_deaths count turtles with [color = red] ; Count of all dead turtles (red color indicates death)
  set pink_deaths count turtles with [group = "pink turtle" and color = red] ; Dead turtles in pink group
  set gray_deaths count turtles with [group = "gray turtle" and color = red] ; Dead turtles in gray group

  ; Calculating the percentages for turtles with antibodies (those who developed immunity)
  let total_antibodies count turtles with [antibodies > 0] ; Count turtles with active antibodies (immunity)
  set total_antibodies_percentage (total_antibodies / total_population) * 100 ; Overall immunity percentage

  ; Calculating the antibody percentages within each group (pink and gray)
  let pink_antibodies count turtles with [group = "pink turtle" and antibodies > 0] ; Pink group immunity
  set pink_antibodies_percentage (pink_antibodies / pink_population_count) * 100 ; Pink group immunity percentage

  let gray_antibodies count turtles with [group = "gray turtle" and antibodies > 0] ; Gray group immunity
  set gray_antibodies_percentage (gray_antibodies / gray_population_count) * 100 ; Gray group immunity percentage

end






; Defining  a procedure to perform analysis based on simulation results
to my_analysis
  ; Set variables based on simulation findings (values here are placeholders)
  set most_effective_measure 1   ; Assign the most effective measure based on analysis
  set least_effective_measure 2     ; Assign the least effective measure based on analysis
  set population_with_highest_mortality_rate 1  ; Identify the population group with the highest mortality rate
  set population_most_immune 2   ; Identify the population group with the highest immunity level
  set self_isolation_link 4   ; Placeholder link/reference related to self-isolation
  set population_density 5   ; Placeholder for calculated population density
end

; Defining a helper function to determine if a turtle is self-isolating
to-report self-isolating?
  report self_isolation and color = green and infected_time < (illness_duration - undetected_period)
  ; Report true if self-isolation is active, the turtle is infected (green color),
  ; and the infected time is within the detectable illness period
end




@#$#@#$#@
GRAPHICS-WINDOW
188
12
928
753
-1
-1
4.0
1
3
1
1
1
0
1
1
1
-91
91
-91
91
1
1
1
hours
20.0

BUTTON
7
10
82
43
NIL
setup_world
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
10
166
43
setup_agents
setup_agents
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
63
44
152
77
NIL
run_model
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
9
81
181
114
pink_population
pink_population
0
1500
1500.0
1
1
NIL
HORIZONTAL

SLIDER
10
116
182
149
gray_population
gray_population
0
1500
1000.0
1
1
NIL
HORIZONTAL

SLIDER
11
153
183
186
initially_infected
initially_infected
0
1500
15.0
1
1
NIL
HORIZONTAL

SLIDER
11
189
183
222
infection_rate
infection_rate
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
11
224
183
257
survival_rate
survival_rate
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
12
260
184
293
immunity_duration
immunity_duration
0
500
260.0
1
1
NIL
HORIZONTAL

SLIDER
12
294
184
327
undetected_period
undetected_period
0
300
75.0
1
1
NIL
HORIZONTAL

SLIDER
12
329
184
362
illness_duration
illness_duration
0
300
290.0
1
1
NIL
HORIZONTAL

SWITCH
13
364
169
397
travel_restrictions
travel_restrictions
1
1
-1000

SWITCH
13
398
140
431
self_isolation
self_isolation
1
1
-1000

SWITCH
13
433
161
466
social_distancing
social_distancing
1
1
-1000

MONITOR
933
15
1094
60
total_infected_percentage
66.32
17
1
11

MONITOR
1118
108
1275
153
pink_infected_percentage
67.47
17
1
11

MONITOR
1296
109
1457
154
gray_infected_percentage
64.6
17
1
11

MONITOR
935
61
1018
106
total_deaths
0
17
1
11

MONITOR
1118
62
1198
107
pink_deaths
0
17
1
11

MONITOR
1293
62
1376
107
gray_deaths
0
17
1
11

MONITOR
936
107
1108
152
total_antibodies_percentage
0
17
1
11

MONITOR
1109
15
1278
60
pink_antibodies_percentage
0
17
1
11

MONITOR
1290
15
1462
60
gray_antibodies_percentage
0
17
1
11

PLOT
937
196
1408
346
populations
Time
Agents
0.0
600.0
0.0
1650.0
true
true
"" ""
PENS
"pink polulation" 1.0 0 -2139308 true "" "plotxy ticks count turtles with [group = \"pink turtle\"]\n"
"gray population" 1.0 0 -7500403 true "" "plotxy ticks count turtles with [group = \"gray turtle\"]\n"

PLOT
936
343
1407
493
Population
Hours
Number of People
0.0
100.0
0.0
1820.0
true
true
"" ""
PENS
"Infected" 1.0 0 -15575016 true "" "plotxy ticks count turtles with [ color = green]"
"Immune" 1.0 0 -16777216 true "" "plotxy ticks count turtles with [ color = black ]"

MONITOR
937
154
1019
199
Active cases
0
17
1
11

MONITOR
1026
154
1109
199
count turtles
2500
17
1
11

MONITOR
1119
154
1259
199
current pink population
1500
17
1
11

MONITOR
1295
156
1438
201
current gray population
1000
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
