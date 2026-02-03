local HttpService = game:GetService("HttpService")
local Types = require("../Types")

local Container = {}
Container.__index = Container

function Container.new(part: BasePart): Types.Container
	local self = {
		Id = HttpService:GenerateGUID(false),
		Bags = {},
		Part = part,
	}

	return setmetatable(self, Container) :: any
end

function Container.addBag(self: Types.Container, bag: Types.Bag)
	if bag.Container then
		error("Add bag cannot add a bag that already has a container... Please move the bag instead.")
	end

	bag.Container = self
	table.insert(self.Bags, bag)
end

function Container.removeBag(self: Types.Container, bag: Types.Bag)
	if not bag.Container then
		error("The given bag did not have a container")
	end

	if bag.Container ~= self then
		error("Cannot remove bags from other containers")
	end

	local i = table.find(self.Bags, bag)
	if not i then
		error("The bag was for some reason already removed from the bag table..")
	end
	table.remove(self.Bags, i)
end

function Container.serialze(self: Types.Container): Types.SerializedContainer
	return {
		Id = self.Id,
		Type = "Container",
	}
end

return Container
