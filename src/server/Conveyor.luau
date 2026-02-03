local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Math = require("./Math")
local Types = require("./Types")

local Conveyors: { [BasePart]: Types.Conveyor } = {}
local Bags: { [string]: Types.Bag } = {}

local function New(part: BasePart, speed: number)
	local conveyor: Types.Conveyor = {
		Bags = {},
		Speed = speed,
		Part = part,
		POI = { ["End"] = part.Size.Z },
		BagEvents = {}, --Events for when bags reach POI
	}

	--To get even more functionality we could add POI on the conveyor. This could be upgraders etc.
	--These would be points on the conveyor. We would then find the next point for a bag and wait for that point instead of the end.

	Conveyors[part] = conveyor
end

--Add a bag to a specified conveyor.
local function AddBagToConveyor(conveyor: Types.Conveyor, color: BrickColor?, material: Enum.Material?)
	local id = HttpService:GenerateGUID(false)

	local bag: Types.Bag = {
		Color = color or BrickColor.Random(), --Either use selected brickcolor or a random brickcolor
		Material = material or Enum.Material:GetEnumItems()[math.random(1, #Enum.Material:GetEnumItems())], --either use selected material or a random material
		StudsTraversed = 0,
		LastUpdate = tick(),
		Target = "End", --If support for other POI was added, then we'd add a check for closest POI here
	}

	Bags[id] = bag

	table.insert(conveyor.Bags, id)
	conveyor.BagEvents[id] = tick() + Math.TimeRemaining(conveyor, bag.StudsTraversed)
end

RunService.Heartbeat:Connect(function(dt: number) end)

return {
	New = New,
	AddBagToConveyor = AddBagToConveyor,
}
