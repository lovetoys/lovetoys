require 'lovetoys'

describe('Component', function()
  it(':create with defaults creates a Component with default values', function()
    local c = Component.create('TestComponent',
      {'defaultField', 'emptyField'},
      {defaultField = 'defaultValue'})

    local instance = c()
    assert.are.equal(instance.defaultField, 'defaultValue')
    assert.is_nil(instance.emptyField)
  end)
end)
