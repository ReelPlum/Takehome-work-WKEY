local HttpService = game:GetService("HttpService")
local Types = require("../Types")
local Math = require("../Math")

local Conveyor = {}
Conveyor.__index = Conveyor

function Conveyor.new(part: BasePart, speed: number, target: Types.Container): Types.Conveyor
	local self = {
		Id = HttpService:GenerateGUID(false),
		Part = part,
		Bags = {},
		Speed = speed,
		BagEvents = {},
		Target = target,
		POI = {},
	}

	return setmetatable(self, Conveyor) :: any
end

function Conveyor.add(self: Types.Conveyor, bag: Types.Bag)
	if bag.Container then
		error("Add bag cannot add a bag that already has a container... Please move the bag instead.")
	end

	bag.Container = self
	table.insert(self.Bags, bag)

	bag.StudsTraversed = 0
	bag.LastUpdate = tick()

	--Update this function IF POI are added
	self.BagEvents[bag] = tick() + Math.TimeRemaining(self, bag.StudsTraversed)
end

function Conveyor.remove(self: Types.Conveyor, bag: Types.Bag)
	if not bag.Container then
		error("The given bag did not have a container")
	end

	if bag.Container ~= self then
		error("Cannot remove bags from other containers")
	end

	self.BagEvents[bag] = nil

	local i = table.find(self.Bags, bag)
	if not i then
		error("The bag was for some reason already removed from the bag table..")
	end
	table.remove(self.Bags, i)
end

function Conveyor.update(self: Types.Conveyor)
	for bag, t in self.BagEvents do
		if tick() <= t then
			--Reached destination
			--Update this to handle POI if they are ever added

			bag:move(self.Target)
		end
	end
end

function Conveyor.serialize(self: Types.Conveyor): Types.SerializedConveyor
	local bags = {}
	for _, bag in self.Bags do
		table.insert(bags, bag:serialize())
	end

	return {
		Speed = self.Speed,
		Target = self.Target:serialize(),
		Type = "Conveyor",
		Id = self.Id,
		POI = {},
		Bags = bags,
		Part = self.Part,
	}
end

return Conveyor
