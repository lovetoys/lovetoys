## 0.3

- Replace Engine:addInitializer() and Engine:removeInitializer with System:onAddEntity().
- Add rockspec
- **Breaking Change**: require('lovetoys') now returns a factory function that accepts an optional configuration object. See README for configuration details

## 0.2

- Add Component.create() and Component.register(). See the readme for more information.
- Switch to middleclass for object orientation
