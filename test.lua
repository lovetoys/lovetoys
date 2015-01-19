require 'lovetoys'

function len(t)
  local c = 0
  for _, _ in pairs(t) do
  	c = c + 1
  end
  return c
end

-- character, type1, type2, active
C, T1, T2, A = class('C', Component), class('T1', Component), class('T2', Component), class('A', Component)

local e1, e2 = Entity(), Entity()


-- type 1 character who is active
e1:add(C())
e1:add(T1())
e1:add(A())

-- type 2 character, not active
e2:add(C())
e2:add(T2())


local S = class('S', System)

function S:draw() end

function S:requires() 
  return {activeCharacters = {'A'}, allCharacters = {'C'}}
end

local s = S()

local engine = Engine()
engine:addSystem(s)

engine:addEntity(e1)
engine:addEntity(e2)

assert(1 == len(s.targets.activeCharacters))
assert(2 == len(s.targets.allCharacters))

-- make e1 non-active
e1:remove('A')
assert(0 == len(s.targets.activeCharacters))
assert(2 == len(s.targets.allCharacters))

-- mark e2 as active
e2:add(A())
assert(1 == len(s.targets.activeCharacters))
assert(2 == len(s.targets.allCharacters))
