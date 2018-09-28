package = 'lovetoys'
version = '0.4.0-1'
source = {
  url = "git://github.com/lovetoys/lovetoys",
  branch = "master"
}
description = {
  summary = 'A neat Entity-Component-System for Lua',
  detailed = [[
    Lovetoys is a full-featured game development framework, not only providing the core parts like Entity, Component and System classes but also containing a Publish-Subscribe messaging system as well as a Scene Graph, enabling you to build even complex games easily and in a structured way.
  ]],
  homepage = 'http://github.com/lovetoys/lovetoys',
  license = 'MIT <http://opensource.org/licenses/MIT>'
}
dependencies = {
  'lua >= 5.1'
}
build = {
  type = 'builtin',
  modules = {
    ['lovetoys.src.namespace']                           = 'src/namespace.lua',
    ['lovetoys.lovetoys']                                = 'lovetoys.lua',
    ['lovetoys.src.Component']                           = 'src/Component.lua',
    ['lovetoys.src.Engine']                              = 'src/Engine.lua',
    ['lovetoys.src.Entity']                              = 'src/Entity.lua',
    ['lovetoys.src.EventManager']                        = 'src/EventManager.lua',
    ['lovetoys.lib.middleclass']                         = 'lib/middleclass.lua',
    ['lovetoys.src.System']                              = 'src/System.lua',
    ['lovetoys.src.util']                                = 'src/util.lua',
    ['lovetoys.src.events.ComponentAdded']               = 'src/events/ComponentAdded.lua',
    ['lovetoys.src.events.ComponentRemoved']             = 'src/events/ComponentRemoved.lua',
  }
}
