local Physic = Component.create("Physic")

function Physic:initialize(body, fixture, shape)
    self.body = body
    self.shape = shape
    self.fixture = fixture
end
