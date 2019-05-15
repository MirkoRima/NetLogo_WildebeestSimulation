;----------------------------- Global definitions -----------------------------
;Global variables:
; - wildebeestseatenbylions: number of wildebeests eaten by lions
; - wildebeestseatenbycrocs: number of wildebeests eaten by crocodiles
; - wildebeestsdrowned: number of wildebeests drowned
; - cont: variable to count the number of sub-heards until reaching the full herd size
; - crowding?: is time to flocking crowding to the river banks while waiting for the leaders choice?
; - firstleader?: is the wildebeest a hypotetic first leader?
; - approachpoint: river approach point for the herd (first leader choose it)
; - lionsattacks: number of lion's attacks
globals [wildebeestseatenbylions wildebeestseatenbycrocs wildebeestsdrowned cont crowding? firstleader? approachpoint lionsattacks]
;Define new turtle breed: Wildebeest, Lions and Crocodiles
breed [wildebeests wildebeest] ;[plural singolar]
breed [lions lion]
breed [crocodiles crocodile]
; Wildebeests-only characteristics:
; - sex: 0-female, 1-male, 2-calves
; - target: their prior target before following each other
; - waitforleadership: counter to force wildebeests to wait until some wildebeest choose to be leader
; - leadership?: leader or not leader?
; - flockmates, nearest-neighbor: flocking parameters
; - status: movement status of the wildebeest:
;           0 - before the river: flocking as a compact herd
;           1 - near to the river: crowding on the river bank and wait for the leaders choice
;           2 - crossing the river: flocking more slowly, forming a single row or a couple of rows
;           3 - over the river: flocking spreading a bit more facing the target
;           4 - lion alert --> evasion
;           5 - lion no more a alert --> pursuit
;           6 - stop status: job done --> set agent as hidden
; - crossing?: is the wildebeest crossing the river?
; - timealone: time alone in water
; - firstimeatacked?: is the first time (of each attack) that the wildebeest notice the predator?
; Assumption: a wildebeest die if spend to much time alone (herd effect)
wildebeests-own [sex target waitforleadership leadership? flockmates nearest-neighbor status crossing? timealone firsttimeattacked?]
; Lions characteristics:
; - status: movement status of the lion
;           0 - relax status: lion walk random
;           1 - alert status: lion notice wildebeests presence and slowly walk towards them to prepare an ambush
;           2 - targeting status: lion at attack distance, wait for the right target to make an ambush
;           3 - hunting status: lion choose the target and try the ambush
;           4 - escape without hunting status: lion fails to choose the target, too much wildebeests in the zone,
;                                              escape and then back to status 1 to try to catch again
;           5 - satiated status escape: a lion that has already eaten a prey that have to escape from a big herd
;           6 - satiated status: a lion that has already eaten a prey, slowly walk away cause it is sated
;           7 - failed attack status: a lion that fails an attack, walk away or escape and prepare another attack
; - waitingtime: time spent waiting for targeting a prey. If is too much give up and try again later
; - accelerationtime: time spent accelerating. Lions can't hold high speed for long time
; Assumption: a lion kill a single prey and then stop the hunt
lions-own [status waitingtime accelerationtime]
; Crocodiles characteristcis:
; - still not implemented
;crocodiles-own [status]
;------------------------------------------------------------------------------


;------------------------------ Setup functions -------------------------------
; Functions to setup the environment (background and parameters)

; Setup the environment
to setup
  ; Remove old agents
  clear-all
  ; Global variables handler
  modify-vars
  ; Import right Mara river image (according with the global variables) and set it as background of the grid
  import-background
  ; Define wildebeests default area
  let patches-in-box patches with [pxcor > 100 and pycor < -100 ] ;100 -100
  ; Set number of initial sub-group (100k each subgroup) of wildebeests
  set cont 1
  ; Call to wildebeests generator with default area as parameter
  wildebeest-generator (patches-in-box)
  ; Set crowding? as initially false
  set crowding? false
  ; Set firstleader? as initially false
  set firstleader? true
  ; Call to lions generator
  lions-generator
  ; Call to crocodiles generator
  ;crocodiles-generator
  ; Reset ticks to start a new simulation
  reset-ticks
end

; Change global variables in according with the relations between them (look at the report)
to modify-vars
  ifelse constraints? [
    ; If constraints are on
    ; month --> rain
    if month = "June" [
      set rain-level 3 ;work only when someone click "setup"
      output-print "Rain level changed to 3"
    ]
    if month = "July" [
      set rain-level 1 ;work only when someone click "setup"
      output-print "Rain level changed to 1"
    ]
    if month = "August" [
      set rain-level 2 ;work only when someone click "setup"
      output-print "Rain level changed to 2"
    ]
    if month = "September" [
      set rain-level 2 ;work only when someone click "setup"
      output-print "Rain level changed to 2"
    ]
    if month = "October" [
      set rain-level 2 ;work only when someone click "setup"
      output-print "Rain level changed to 2"
    ]
    ; rain --> river-flow
    if rain-level = 1 [
      set river-flow 1
      output-print "River flow level changed to 1"
    ]
    if rain-level = 2 and river-flow = 4 [ ;error
      set river-flow 2 ;or 1 or 3
      output-print "River flow level can't be 4 with rain level 2. River flow changed to 2, can be also 1 or 3)"
    ]
    if rain-level = 3  and river-flow = 1 [
      set river-flow 2;
      output-print "River flow level can't be 1 with rain level 3. River flow changed to 2, can be also 3 or 4"
    ]
    ; flow --> [depth, width, speed]
    if river-flow = 1 [
      set river-depth 1
      set river-width 1
      set river-speed 1
      output-print "River depth, width and speed levels changed"
    ]
    if river-flow = 2 and river-depth = 3 [ ;and (river-width = 3) and (river-speed = 3) [
      set river-depth 2 ;or 1
      output-print "River depth level cann't be 3 with river flow level 2. River depth changed to 2, can be also 1"
    ]
    if river-flow = 2 and river-width = 3 [
      set river-width 2 ;or 1
      output-print "River width level cannot be 3 with river flow level 2. River width changed to 2, can be also 1"
    ]
    if river-flow = 2 and river-speed = 3 [
      set river-speed 2 ;or 1
      output-print "River speed level cannot be 3 with river flow level 2. River speed changed to 2, can be also 1"
    ]
    if river-flow = 3 [
      set river-depth 2
      set river-width 3
      set river-speed 2
      output-print "River depth, width and speed levels changed"
    ]
    if river-flow = 4 [
      set river-depth 3
      set river-width 3
      set river-speed 3
      output-print "River depth, width and speed levels changed"
    ]
  ] [
    ; else, if contstraints are off, check only width and depth
    output-print "Constraints off: only width and depth checked"
    if river-width = 1 and river-depth != 1 and river-depth != 2 [
      set river-depth 2
      output-print "River depth changed in according with river-width"
    ]
    if river-width = 2 and river-depth != 1 and river-depth != 2 [
      set river-depth 2
      output-print "River depth changed in according with river-width"
    ]
    if river-width = 3 and river-depth != 2 and river-depth != 3 [
      set river-depth 3
      output-print "River depth changed in according with river-width"
    ]
  ]
end

; Choose the right background in according to river-width and river-depth
to import-background
  import-pcolors "img/marariver11.png"
  if river-width = 1 and river-depth = 2 [
    import-pcolors "img/marariver12.png"
  ]
  if river-width = 2 and river-depth = 1 [
    import-pcolors "img/marariver21.png"
  ]
  if river-width = 2 and river-depth = 2 [
    import-pcolors "img/marariver22.png"
  ]
  if river-width = 3 and river-depth = 2 [
    import-pcolors "img/marariver32.png"
  ]
  if river-width = 3 and river-depth = 3 [
    import-pcolors "img/marariver33.png"
  ]
end
;------------------------------------------------------------------------------


;----------------------------- Turtles' creation ------------------------------
; Functions to create all the agents of the simulation

; Generate wildebeest and distribute them normally in the bottom-right corner
to wildebeest-generator [box]
  ; Default shape for wildebeests agent
  set-default-shape wildebeests "default"
  ; Number of wildebeests
  let pop 100
  let ys [ pycor ] of box
  let xs [ pxcor ] of box
  let min-x min xs
  let min-y min ys
  let max-x max xs
  let max-y max ys
  let mid-x mean list min-x max-x
  let mid-y mean list min-y max-y
  let w max-x - min-x
  let h max-y - min-y
  ; Create "pop" wildebeests
  create-wildebeests pop [
    loop [
      ; Default charactertistics and parameters
      set size 2.5
      set color black
      set status 0
      ; Choose the sex in according with the sex probability distribution in a wildebeests herd
      let prob random 100.0
      ifelse prob <= 22 [
        ; calves (22%)
        set sex 2
      ] [
        ifelse prob > 22 and prob <= 49.5 [ ;49.5 = 22 + 27.5
          ; male (27.5%)
          set sex 1
        ] [
          ; female (50.5%)
          set sex 0
        ]
      ]
      set waitforleadership 0
      ; Default leadership value --> no default leaders, choosen at the crossing moment
      set leadership? false
      set crossing? false
      set timealone 0
      set firsttimeattacked? true
      set flockmates no-turtles
      ; Set normally distributed position in the default area
      ; OBS: normal cause replicate better a herd than a uniform
      let x random-normal mid-x (w / 6)
      if x > max-x [ set x max-x ]
      if x < min-x [ set x min-x ]
      set xcor x
      let y random-normal mid-y (h / 6)
      if y > max-y [ set y max-y ]
      if y < min-y [ set y min-y ]
      set ycor y
      if not any? other turtles-here [ stop ]
    ]
    ; Center in patch
    move-to patch-here
  ]
end

;Generate lion agents
;OBS: Generate at at least X distance from the wildebeest herd and not on-water
to lions-generator
  ; Default shape
  set-default-shape lions "default"
  if lions? [
    ; if lions? is true (lions presence true) create them
    ask n-of lions-number patches with [on-water? = false and count wildebeests in-radius 30 < 1 and pxcor > -50] [
      sprout-lions 1 [
        ; Default characteristics and parameters value
        set size 2
        set color yellow
        set status 0
        set accelerationtime 0
        set waitingtime 0
        ; if too much near to the water move the lion away
        if (count patches with [on-water?] in-radius 5 > 0) [
          move-to one-of patches with [count patches with [on-water? = false] in-radius 5 = 0]
        ]
      ]
    ]
  ]
end

; Generate crocodile agents [NOT YET IMPLEMENTED]
;to crocodiles-generator
  ;set-default-shape crocodiles "default"
  ;let numcrocodiles 0
  ;if crocodiles?[
    ;set numcrocodiles crocs-number
  ;]
  ;ask n-of numcrocodiles (patches with [on-water?]) [
  ;  sprout-crocodiles 1 [
  ;    set size 3.5
  ;    set color lime
  ;  ]
  ;]
;end
;------------------------------------------------------------------------------


;-------------------------------- Go functions --------------------------------
; Functions to handle simulation tick by tick

; Ticks function --> "main"
to go
  ; Create the herd (with sub-herds if existent)
  if wildebeests-number = 100 [
    set wildebeests-sub-herds 1
  ]
  if wildebeests-number = 200 and wildebeests-sub-herds = 3 [
    set wildebeests-sub-herds 2
  ]
  let sub-herds-size 0 ;all wildebeests in a single herd
  let lastsubherdsbigger? false
  ; Compute sub-herds size with known number of sub-herds
  if wildebeests-sub-herds > 1 [
    set sub-herds-size (wildebeests-number / wildebeests-sub-herds)
    if sub-herds-size mod 100 != 0 and sub-herds-size + 50 < ((ceiling (sub-herds-size / 100)) * 100) [
      ; last sub-herds has to be bigger then the others
      set lastsubherdsbigger? true
    ]
    if sub-herds-size mod 100 != 0 [
      ; Round to next hundred
      set sub-herds-size ((round (sub-herds-size / 100)) * 100)
    ]
  ]
  ; Call to create-herd function
  create-herd (sub-herds-size) (lastsubherdsbigger?)
  ; If no turtles alive stop the simulation
  if not any? turtles [ stop ]
  ; Call to go function for wildebeests
  go-wildebeests
  ; Call to go function for wildebeests
  go-lions
  tick
end

; Function to create the herd of wildebeests. Creates as many sub-herds as wildebeests-sub-herds value
; Herd: all the wildebeests
; Group: group of 100k widlebeests
;  - create more group of 100k to simulate a herd already in movement
; Sub-Herd: 1 or more group of wildebeests
;  - in each sub-herd group generated every 100 ticks
;  - each sub-herd is generated every 200 ticks
to create-herd [sub-herds-size last-sub-herds-bigger?]
  ifelse wildebeests-sub-herds = 1 [
    ; if a single herd
    let num 100 ;num: ticks between each group
    if ticks > 0 and ticks mod num = 0 and cont < wildebeests-number / 100 [
      let patches-in-box patches with [pxcor > 100 and pycor < -100 ]
      ; Call to wildebeests group generator function
      wildebeest-generator patches-in-box
      set cont cont + 1
    ]
  ][
    ; else (more sub-herds)
    let new-sub-herds? false
    if (cont * 100) mod sub-herds-size = 0 [
      set new-sub-herds? true
    ]
    let num 100 ;100 ticks between each group
    ; Time for a new-sub-herds?
    if new-sub-herds? [
      set num 2000 + (sub-herds-size * 4);
    ]
    if last-sub-herds-bigger? [
      if (cont * 100) + sub-herds-size >= wildebeests-number [
        set num 100
      ]
    ]
    if ticks > 0 and ticks mod num = 0 and cont < wildebeests-number / 100 [
      let patches-in-box patches with [pxcor > 100 and pycor < -100 ]
      wildebeest-generator patches-in-box
      set cont cont + 1
    ]
  ]
end

; Go function for the wildebeests
to go-wildebeests
	ask wildebeests [
    ifelse status != 6 [
      ; if not hidden (job done status)
      if status != 4 [
        ; if not in evasion face a random target (over the river)
        set target patch (random-int-between -80 120) 120
        face target
      ]
      ; Eevasive wildebeest that change to status 3 cause finish to cross the river and forget to be in status 4
      if color = green [
        set status 4
      ]
      ; Wildebeest in pursuit that change to status 3 cause finish to cross the river and forget to be in status 5
      if color = blue [
        set status 5
      ]
      ; Set number of leaders (can be more then 1, but not too much, cause when wildebeests are in the water
      ; the ones on the banks simply follow the herd and not the leaders anymore)
      let number-of-leaders random-int-between 1 5
      ; 0) Default Status: 0 - before arriving at the river banks
      ; 1) Check if Status is 1
      let closetowater? (count patches in-radius 3 with [on-water?] > 0 and status = 0)
      if closetowater? [
        set status 1
      ]
      ; 2) Check if Status is 2
      if on-water? [
        set status 2
      ]
      ; 3) Check if Status is 3
      if (on-water? = false) and crossing? [
        set status 3
        set crossing? false
      ]
      ; 4) Check if status is 4
      ; OBS: lions attack a wildebeest from radius 12, but wildebeest see it only in radius 10
      ;  why? wildebeests, that are usually vigilant, are less vigilant if they're migrating
      if (count lions with [status = 3] in-radius 10 > 0 and count wildebeests in-radius 2 < 2) [
        set status 4
      ]
      ; 5) Check if status is 6
      if ycor > 118 [
        set status 6
      ]
      ;Status 0: normal flocking before the river banks
      if status = 0 [
        ifelse crowding? [
          ; if crowding? flocking crowding and spreading on the river banks
          ; OBS: this is the case when some wildebeests are already on the river banks and the others no
          to-flock 10 10 0 0 ;min-sep, sep, ali, coh
          ifelse [distance myself] of approachpoint < 10 [
            fd 0.02		
          ][
            ifelse [distance myself] of approachpoint < 20 [
              fd 0.04
            ][
              ifelse [distance myself] of approachpoint < 30 [
                fd 0.06
              ][
                ifelse [distance myself] of approachpoint < 40 [
                  fd 0.08
                ][
                  to-flock 1 2 5 4 ; flock as status 0
                  fd 0.1
                ]
              ]
            ]
          ]
        ] [
          ; if not, default flocking, quite compact herd in march
          to-flock 1 2 5 4 ;min-sep, sep, ali, coh
          fd 0.1
        ]
      ]
      ; Status 1: near the river bank, wait for the leaders to start the crossing
      if status = 1 [
        if firstleader? [
          ; if the wildebeest is a hypothetic first leader
          set crowding? true ; false - default flocking, true - crowding (for the wildebeests with status 0)
          set approachpoint patch-here
          set firstleader? false
          stop
        ]
        ifelse count wildebeests with [ leadership? ] <= number-of-leaders [
          set waitforleadership (waitforleadership + 1)
          if waitforleadership >= 50 and sex = 1 [
            ; Wait enough --> choose to be leader (if the wildeebest is male)
            set leadership? true
            set color red
            ; Set next status --> time to cross the river
            set status 2
          ]
        ][
   		  	;else, so if there are already enough leaders, if on-water? set status to 2
          set status 2
     	  ]
      ]
      ; Status 2: crossing the river, tryi to swim in one or more rows
      ; OBS: wildebeests wait until they have enough space to jump and start to swim,
     ;       only a little fraction of the herd swim at any time
      if status = 2 [
        if on-water? [
          set crossing? true
        ]
        ; Set max-density dependent to river width and wildebeests sub-herds numerosity
        let max-density 0
        let sub-herds ((round ((wildebeests-number / wildebeests-sub-herds) / 100)) * 100)
        if river-width = 1 [
          if sub-herds < 201 [
            set max-density 30
          ]
          if sub-herds < 401 and sub-herds > 200 [
            set max-density 35
          ]
          if sub-herds < 601 and sub-herds > 400 [
            set max-density 40
          ]
          if sub-herds < 801 and sub-herds > 600 [
            set max-density 45
          ]
          if sub-herds > 800 [
            set max-density 50
          ]
        ]
        if river-width = 2 [
          if sub-herds < 201 [
            set max-density 40
          ]
          if sub-herds < 401 and sub-herds > 200 [
            set max-density 45
          ]
          if sub-herds < 601 and sub-herds > 400 [
            set max-density 50
          ]
          if sub-herds < 801 and sub-herds > 600 [
            set max-density 55
          ]
          if sub-herds > 800 [
            set max-density 60
          ]
        ]
        if river-width = 3 [
          if sub-herds < 201 [
            set max-density 50
          ]
          if sub-herds < 401 and sub-herds > 200 [
            set max-density 55
          ]
          if sub-herds < 601 and sub-herds > 400 [
            set max-density 60
          ]
          if sub-herds < 801 and sub-herds > 600 [
            set max-density 65
          ]
          if sub-herds > 800 [
            set max-density 70
          ]
        ]
        ifelse (count wildebeests with [status = 2 and on-water?]) < max-density [
          ; If there aren't enough wildebeests already in the water jump and join the herd
          ; Flocking in row/rows
          to-flock 0.25 1 6 1.5 ;min-sep, sep, ali, coh
          ; Count neighbors on the left side (water flux from right to left)
          ifelse count [turtles-on patch-set (list patch-at 1 0 patch-at -1 0 patch-at -1 -1)] of self < 1 [
            ; if alone --> suffer more from water flux and speed --> divert max
            left (random-int-between 20 30) * ((river-speed + river-flow + 2) / 4)
          ] [
            ifelse count [turtles-on patch-set (list patch-at 1 0 patch-at -1 0 patch-at -1 -1)] of self < 2 [
              ; if not enough neighbors on the left --> divert to the left more then the others
              left (random-int-between 10 20) * ((river-speed + river-flow + 2) / 4)
            ] [
              ; if in the herd, divert only a bit
              left (random-int-between 5 10) * ((river-speed + river-flow + 2) / 4)
            ]
          ]
          ifelse sex = 2 or sex = 1 [
            ; Calves and adult females (swim slower then males and more quiet)
            fd 0.05
          ] [
            ; Adult males (faster and braver then calves and women)
            fd 0.06
          ]
        ] [
          ; If there are already enough wildebeests in the water
          if on-water? [
            ; If the wildebeest is already in water continues to swim
            to-flock 0.25 1 6 1.5
            ; Count neighbors on the left side (water flux from right to left)
            ifelse count [turtles-on patch-set (list patch-at 1 0 patch-at -1 0 patch-at -1 -1)] of self < 1 [
              left (random-int-between 20 30) * ((river-speed + river-flow + 2) / 4)
            ][
              ifelse count [turtles-on patch-set (list patch-at 1 0 patch-at -1 0 patch-at -1 -1)] of self < 2 [
                left (random-int-between 10 20) * ((river-speed + river-flow + 2) / 4)
              ][
                left (random-int-between 5 10) * ((river-speed + river-flow + 2) / 4)
              ]
            ]
            ifelse sex = 2 or sex = 1 [
              fd 0.05
            ] [
              fd 0.06
            ]
          ]
          ; If not yet in the water -->
          ; do nothing and wait until enough wildebeests complete the crossing to jump in the river
        ]
      ]
      ; Status 3: over the river, flocking spreading a bit facing the end of the grid
      if status = 3 [
        to-flock 3 5 1 1
        fd 0.1
        ; if status 3 and no more wildebeests in water --> a full sub-herd/the full herd has crossed the river
        if count wildebeests with [on-water?] = 0 and count wildebeests with [status = 1] = 0[
          ask wildebeests [
            ; no more leaders
            set leadership? false
          ]
          ; set parameters as default for the next sub-herd
          set crowding? false
          set firstleader? true
        ]
      ]
      ; Status 4: predation --> evasion
      if status = 4 [
        set color green
        ; escape
        ifelse firsttimeattacked? [
          ; escape to the right
          ifelse count [turtles-on patch-set (list patch-at 1 0 patch-at -1 0 patch-at -1 -1)] of self > 1 [
            face patch 120 120
            fd 0.12
          ] [
            ;escape to the left
            face patch -120 120
            fd 0.12
          ]
          set firsttimeattacked? false
        ] [
          set heading (heading + random-int-between -10 10)
          fd 0.12
        ]
        ; if no more hungry lions near to you --> pursuit until reach again the herd
        if count lions with [status != 5] in-radius 10 < 1 [
          ; pursuit mode
          set status 5
          set firsttimeattacked? true
        ]
      ]
      ; Status 5: pursuit mode
      if status = 5 [
        ; come back to the herd
        set color blue
        let the-herd (one-of wildebeests with [count wildebeests in-radius 2 > 2] in-radius 50)
        face the-herd
        ; if about to catch up with the herd, don't pass the leader, only pull even with it
        ifelse distance the-herd > 1 [
          fd 0.12
        ][
          move-to the-herd
          set color black
          ; Back to the status of the herd
          set status [status] of the-herd
        ]
      ]
      ; Handle wildebeests life
      ; ASSUMPTION: wildebeests drown cause they spend to much time alone in depth water
      if count other wildebeests in-radius 3.5 < 1 and on-depth-water? and timealone < 15 [
        set timealone (timealone + 1)
      ]
      if timealone >= 15 [
        set wildebeestsdrowned wildebeestsdrowned + 1
        ; When no energy --> die
        die
      ]
    ] [
      ; Stop status: job done!
      set hidden? true
    ]
  ]
end

; Go function for lions
to go-lions
  ask lions [
    ; Assumption: no lions on water
    if count patches in-radius 5 with [on-water?] > 0 [
      ; If close to water change directory
      fd -0.2
      set heading (heading + (random-int-between -10 10))
      fd 0.1
    ]
    if on-water? [
      move-to one-of (patches with [on-water? = false])
      set heading (heading + (random-int-between -150 -210 ))
      fd 0.1
    ]
    ; Status 0: relax, random walk before a alert
    if status = 0 [
      rt random-int-between -10 10
      fd 0.03
      ; Check for a possible alert
      let possiblewildebeest one-of wildebeests in-radius 50
      if possiblewildebeest != nobody [
        ; if alert
        face possiblewildebeest
        set status 1
      ]
    ]
    ; Status 1: alerted, face the possible prey and slowly try to get near to it/them
    ; OBS: not a real ambush, cause when wildebeests migrate they're too much annd they also ignore more predators
    if status = 1 [
      let possiblewildebeest one-of wildebeests in-radius 50
      ; If alert is real
      ifelse possiblewildebeest != nobody [
        face possiblewildebeest
        fd 0.05
        ; Prey targeting: check for a probable prey
        let probablewildebeest one-of (wildebeests with [count wildebeests in-radius 2 < 3]) in-radius 12
        if probablewildebeest != nobody [
          face probablewildebeest
          set status 2
        ]
        if count wildebeests in-radius 3 > 3 [
          ; theorically is IMPOSSIBLE from this state, keep it here to be sure
          ; escape
          rt 180
          set status 4
        ]
      ][
        ; false alert
        set status 0
      ]
    ]
    ; Status 2: targeting mode, near to on or more target prey, wait until try to attack
    if status = 2 [
      ; try to attack (if exist a real target: wildebeest in radius 5 with only 1 neighbor)
      let prey one-of (wildebeests with [count wildebeests in-radius 2 < 2]) in-radius 12
      ifelse prey != nobody [
        ; Approach the target if is enough alone
        face prey
        fd 0.15
        set status 3
      ] [
        ; Wait for attack
        set waitingtime waitingtime + 1
        let prey2 one-of wildebeests in-radius 5
        if prey2 = nobody [
          ; Prey no more killable --> wrong targeting
          set status 1
        ]
        if waitingtime > 100 [
          ; Impossible targeting, give up for the moment
          set status 1
          set waitingtime 0
        ]
      ]
      if count wildebeests in-radius 3 > 3 [
        ; escape
        rt 180
        set status 4
      ]
    ]
    ; Status 3: try to kill
    if status = 3 [
      ; try to kill
      set lionsattacks (lionsattacks + 1)
      fd 0.2
      let prey one-of wildebeests-on neighbors with [count wildebeests in-radius 2 < 2]
      ifelse prey != nobody [
        ; approach to the prey
        face prey
        fd 0.1
        if [distance myself] of prey < 1 and count wildebeests in-radius 1 < 2 [
          ; predation
          ask prey [ die ]
          set wildebeestseatenbylions wildebeestseatenbylions + 1
          set status 6
        ]
      ] [
        set status 2
      ]
      set accelerationtime accelerationtime + 1
      if accelerationtime > 100 [
        rt 180
        ; Tired, stop the attack and go away
        set status 7
      ]
      if count wildebeests in-radius 3 > 3 [
        ; escape
        rt 180
        set status 4
      ]
    ]
    ; Status 4: escape mode, warned from to many wildebeest choose to run away a bit
    if status = 4 [
      ifelse count wildebeests in-radius 15 < 1 [
        set status 1
      ] [
        ifelse count wildebeests in-radius 5 > 1 [
          ; acceleration phase
          fd 0.15
        ] [
          ; simply run
          fd 0.08
          ; one single wildebeest, try to catch him again
          set status 1
        ]
      ]
    ]
    ; Status 5: escape from a big herd, but don't try to hunt again then
    if status = 5 [
      ifelse count wildebeests in-radius 15 < 1 [
        set status 6
      ] [
        ifelse count wildebeests in-radius 5 > 1 [
          fd 0.15
        ][
          fd 0.05
        ]
      ]
    ]
    ; Status 6: satiated, walk away
    if status = 6 [
      set color orange
      fd 0.05
      rt random-int-between -10 10
      if count wildebeests in-radius 3 > 3 [
        ; escape
        rt 180
        set status 5
      ]
    ]
    ; Status 7: failed attack, go away and try again later
    if status = 7 [
      fd 0.05
      rt random-int-between -10 10
      if count wildebeests in-radius 3 > 3 [
        ;escape
        rt 180
        set status 4
      ]
      if count wildebeests in-radius 10 = 0 [
        ; normal status
        set status 0
      ]
    ]
    ; Handle lions life
    if count wildebeests-on neighbors > 4 [
      die
    ]
  ]
end
;------------------------------------------------------------------------------


;--------------------------- Boids model: flocking ----------------------------
; Functions to hanlde the flocking of the herds in according with the boids model
; OBS: check the report to understand the choice of the parameters for each status of the wildebeests

to to-flock [a b c d]
  find-flockmates
  if any? flockmates
  [ find-nearest-neighbor
    let minimum-separation a ;numero di patch per le cui si tengono distanziate mentre si muovono
    ifelse distance nearest-neighbor < minimum-separation
    [ separate b ]
    [ align c
      cohere d] ]
end

to find-flockmates
  ; Research neighnorood size: visual space where every wildebeest look for other ones to join them (aggregation)
  let vision 8
  ; "neighborood"
  set flockmates other wildebeests in-radius vision
end

to find-nearest-neighbor
  set nearest-neighbor min-one-of flockmates [distance myself]
end

to separate [mst]
  ; Separation degree (the lower is it, the less they separate from each other while marching)
  let max-separate-turn mst
  turn-away ([heading] of nearest-neighbor) max-separate-turn
end

to align [mat]
  ; Alignment degree (the higher is it, the more they align)
  let max-align-turn mat
  turn-towards average-flockmate-heading max-align-turn
end

to-report average-flockmate-heading
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

to cohere [mct]
  ; Cohesion degree (the higher is it, the higher is their research for cohesion,
  ; the littler is it and the more they hold their position)
  let max-cohere-turn mct
  turn-towards average-heading-towards-flockmates max-cohere-turn
end

to-report average-heading-towards-flockmates
  let x-component mean [sin (towards myself + 180)] of flockmates
  let y-component mean [cos (towards myself + 180)] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

to turn-towards [new-heading max-turn]
  turn-at-most (subtract-headings new-heading heading) max-turn
end

to turn-away [new-heading max-turn]
  turn-at-most (subtract-headings heading new-heading) max-turn
end

to turn-at-most [turn max-turn]
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end
;------------------------------------------------------------------------------


;------------------------------ Extra functions -------------------------------
; Extra useful functions

; Function to pick a random integer in a range
to-report random-int-between [ min-num max-num ]
  report random (max-num  - min-num) + min-num
end

; Function to report if a agent is on water
to-report on-water?
  report (shade-of? pcolor blue) or (shade-of? pcolor sky) or (shade-of? pcolor cyan)
end

; Function to report if a agent is on depth-water
to-report on-depth-water?
  report (shade-of? pcolor blue)
end
;------------------------------------------------------------------------------
@#$#@#$#@
GRAPHICS-WINDOW
263
11
748
497
-1
-1
1.98
1
10
1
1
1
0
0
0
1
-120
120
-120
120
0
0
1
ticks
30.0

BUTTON
14
427
258
460
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
329
136
362
river-depth
river-depth
1
3
1.0
1
1
NIL
HORIZONTAL

BUTTON
14
462
258
495
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1071
127
1328
345
Lions Kill Ratio
ticks
# kills / # attakcs
0.0
1000.0
0.0
0.2
true
false
"" ""
PENS
"lions" 1.0 1 -1184463 true "" "plot wildebeestseatenbylions / (lionsattacks + 0.0001)"

MONITOR
758
30
946
75
# wildebeests
count wildebeests
17
1
11

MONITOR
950
30
1136
75
# lions
count lions
17
1
11

MONITOR
1141
30
1327
75
# crocodiles
count crocodiles
17
1
11

MONITOR
950
77
1137
122
# lions kills
wildebeestseatenbylions
0
1
11

MONITOR
758
77
946
122
# wildebeests drowned 
wildebeestsdrowned
17
1
11

SLIDER
140
255
257
288
rain-level
rain-level
1
3
2.0
1
1
NIL
HORIZONTAL

SLIDER
15
292
137
325
river-flow
river-flow
1
4
1.0
1
1
NIL
HORIZONTAL

CHOOSER
14
244
137
289
month
month
"June" "July" "August" "September" "October"
3

OUTPUT
758
370
1328
496
11

SLIDER
139
330
258
363
river-width
river-width
1
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
141
292
259
325
river-speed
river-speed
1
3
1.0
1
1
NIL
HORIZONTAL

MONITOR
1142
77
1328
122
# crocodiles kills
wildebeestseatenbycrocs
0
1
11

TEXTBOX
14
411
164
429
Simulation actions:
14
0.0
1

TEXTBOX
14
10
206
40
Wildebeests parameters:
14
0.0
1

TEXTBOX
13
227
265
257
Months, rain and water parameters:
14
0.0
1

TEXTBOX
16
107
166
125
Lions parameters:
14
0.0
1

SWITCH
15
124
135
157
lions?
lions?
1
1
-1000

SLIDER
138
124
258
157
lions-number
lions-number
5
25
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
15
168
165
202
Crocodiles parameters:
14
0.0
1

SWITCH
15
185
137
218
crocodiles?
crocodiles?
0
1
-1000

SLIDER
141
185
260
218
crocs-number
crocs-number
1
5
1.0
1
1
NIL
HORIZONTAL

PLOT
758
127
1068
345
Wildebeests (K) survival
ticks
number
0.0
1000.0
0.0
100.0
true
true
"" ""
PENS
"males" 1.0 0 -8275240 true "" "plot count wildebeests with [sex = 1] "
"females" 1.0 0 -1264960 true "" "plot count wildebeests with [sex = 0] "
"calves" 1.0 0 -4539718 true "" "plot count wildebeests with [sex = 2] "

SWITCH
15
366
257
399
constraints?
constraints?
0
1
-1000

TEXTBOX
757
10
994
44
Informations and Plots area:
14
0.0
1

TEXTBOX
758
352
983
386
Text area (info):
14
0.0
1

SLIDER
14
29
257
62
wildebeests-number
wildebeests-number
100
1000
100.0
100
1
k
HORIZONTAL

SLIDER
14
64
257
97
wildebeests-sub-herds
wildebeests-sub-herds
1
3
1.0
1
1
NIL
HORIZONTAL

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
NetLogo 6.0.3
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
