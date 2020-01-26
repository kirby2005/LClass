local LClass = dofile "LClass.lua"

local C1 = LClass("C1")
print("Class C1", C1)
C1.a = 100

local O1 = C1()
print("Object O1", O1)
print(O1.a)
print(O1.b)