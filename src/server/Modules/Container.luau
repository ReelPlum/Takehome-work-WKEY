local HttpService = game:GetService("HttpService")
local Types = require(script.Parent.Parent.Types)

local function FindBagFromId(bags, id)
	for i, v in bags do
		if v.Id == id then
			return i
		end
	end
end

local Container = {}
Container.__index = Container

function Container.new(part: BasePart): Types.Container
	local self = {
		Id = HttpService:GenerateGUID(false),
		Bags = {},
		Part = part,
	}

	part.Name = self.Id

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

	bag.Container = nil

	local i = FindBagFromId(self.Bags, bag.Id)
	if not i then
		error("The bag was for some reason already removed from the bag table..")
	end
	table.remove(self.Bags, i)
end

function Container.serialize(self: Types.Container): Types.SerializedContainer
	local bags = {}
	for _, bag in self.Bags do
		table.insert(bags, bag:serialize())
	end

	--warn(bags)

	return {
		Id = self.Id,
		Type = "Container",
		Bags = bags,
	}
end

return Container
