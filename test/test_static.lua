local LClass = dofile "../LClass.lua"

local C1 = LClass("C1")
local C2 = LClass("C2", C1)
local C3 = LClass("C3", C2)
C1.static.sa = 200
C2.static.s2a = 300

local O1 = C1()
local O2 = C2()
local O3 = C3()

assert(C1.static.sa == 200)
assert(C2.static.sa == 200)
assert(C3.static.sa == 200)

C2.static.sa = 201
assert(C1.static.sa == 200)
assert(C2.static.sa == 201)
assert(C3.static.sa == 201)

assert(C1.static.s2a == nil)
assert(C2.static.s2a == 300)
assert(C3.static.s2a == 300)