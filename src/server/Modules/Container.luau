local Types = require("../Types")

local Container = {}
Container.__index = Container

function Container.new(part: BasePart): Types.Container
	local self = {
		Bags = {},
		Part = part,
	}

	return setmetatable(self, Container) :: any
end

function Container.addBag(container: Types.Container, bag: Types.Bag) end

function Container.removeBag(container: Types.Container, bag: Types.Bag) end

return Container
