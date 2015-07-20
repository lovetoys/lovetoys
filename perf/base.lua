require('lovetoys')
package.path = 'src/?.lua;'..package.path
local class = require('middleclass')
local Entity = require('Entity')
local Engine = require('Engine')
local System = require('System')
local Component = require('Component')

local luatrace = require('luatrace.profile')

luatrace.tron()

local components = {}
for i = 0, 5, 1 do
  table.insert(components, class('TestComponent'..i, Component))
end

local SmallSystem = class('System', System)
function SmallSystem:update()
  local lol = 1 + 1
end

function SmallSystem:requires()
  return {'TestComponent'}
end

local BigSystem = class('System', System)
function BigSystem:update()
  local lol = 1 + 1
end

local names = {}
for k,component in pairs(components) do
  table.insert(names, component.class.name)
end

function BigSystem:requires()
  return names
end

local engine = Engine()

engine:addSystem(SmallSystem())
engine:addSystem(BigSystem())

local smallEntity = Entity()

smallEntity:add(components[1]())

local bigEntity = Entity()

for k,v in pairs(components) do
  bigEntity:add(v())
end

engine:addEntity(smallEntity)

engine:addEntity(bigEntity)

engine:update(0.1)

engine:removeEntity(smallEntity)

engine:removeEntity(bigEntity)

luatrace.troff()
