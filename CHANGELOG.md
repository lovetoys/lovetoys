## 0.4
- Add System:onRemoveEntity callback
- Add middleclassPath configuration option
- Add Engine:getEntityCount()
- Improve documentation
- Fix some bugs

## 0.3

- Replace Engine:addInitializer() and Engine:removeInitializer with System:onAddEntity().
- Add rockspec
- **Breaking Change**: New mandatory `initialize` function used to specify configuration
- **Breaking Change**: lovetoys doesn't use globals by default anymore. See the README on how to re-enable the old behavior

## 0.2

- Add Component.create() and Component.register(). See the readme for more information.
- Switch to middleclass for object orientation
