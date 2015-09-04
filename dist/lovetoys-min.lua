[179:0] unexpected keyword 'function' near 'table'

Error: failed to minify. Make sure the Lua code is valid.
If you think this is a bug in luamin, please report it:
https://github.com/mathiasbynens/luamin/issues/new

Stack trace using luamin@0.2.8 and luaparse@0.1.15:

SyntaxError: [179:0] unexpected keyword 'function' near 'table'
    at raise (/usr/lib/node_modules/luamin/node_modules/luaparse/luaparse.js:460:15)
    at unexpected (/usr/lib/node_modules/luamin/node_modules/luaparse/luaparse.js:512:14)
    at parseChunk (/usr/lib/node_modules/luamin/node_modules/luaparse/luaparse.js:1243:29)
    at end (/usr/lib/node_modules/luamin/node_modules/luaparse/luaparse.js:2075:17)
    at parse (/usr/lib/node_modules/luamin/node_modules/luaparse/luaparse.js:2051:31)
    at minify (/usr/lib/node_modules/luamin/luamin.js:569:6)
    at /usr/lib/node_modules/luamin/bin/luamin:70:15
    at Array.forEach (native)
    at main (/usr/lib/node_modules/luamin/bin/luamin:55:12)
    at Socket.<anonymous> (/usr/lib/node_modules/luamin/bin/luamin:110:4)
