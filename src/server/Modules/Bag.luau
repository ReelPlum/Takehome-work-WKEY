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
		Target = "End", --If support for other POI was added, then we'd add a check for closest POI here
		Container = nil,
	}

	return setmetatable(self, Bag) :: any
end

function Bag.move(self: Types.Bag, newContainer: Types.Container) end

return Bag
