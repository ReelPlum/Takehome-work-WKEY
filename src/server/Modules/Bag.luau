local HttpService = game:GetService("HttpService")

local Types = require("../Types")

local Bag = {}
Bag.__index = Bag

function Bag.new(brickColor: BrickColor?, material: Enum.Material?): Types.Bag
	local self = {
		Id = HttpService:GenerateGUID(false),
		Color = brickColor or BrickColor.Random(), --Either use selected brickcolor or a random brickcolor
		Material = material or Enum.Material:GetEnumItems()[math.random(1, #Enum.Material:GetEnumItems())], --either use selected material or a random material
		StudsTraversed = 0,
		LastUpdate = tick(),
		Container = nil,
	}

	return setmetatable(self, Bag) :: any
end

function Bag.move(self: Types.Bag, newContainer: Types.Container)
	if not self.Container then
		error("Cannot move a bag that is not assigned to a container already")
	end

	self.Container:removeBag(self)
	newContainer:addBag(self)
end

function Bag.serialize(self: Types.Bag): Types.SerializedBag
	return {
		Id = self.Id,
		Color = self.Color,
		Material = self.Material,
		StudsTraversed = self.StudsTraversed,
		Container = if self.Container then self.Container:serialize() else nil,
	}
end

return Bag
