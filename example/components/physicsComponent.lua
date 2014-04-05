PhysicsComponent = class("PhysicsComponent", Component)

function PhysicsComponent:__init(body, fixture, shape)
    self.body = body
    self.shape = shape
    self.fixture = fixture
end
