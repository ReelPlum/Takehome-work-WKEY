local Conveyor = require("../Conveyor")
local Types = require("../Types")

local Conveyor = {}
Conveyor.__index = Conveyor

function Conveyor.new(part: BasePart, speed: number): Types.Conveyor
	local self = {
		Part = part,
		Bags = {},
		Speed = speed,
		BagEvents = {},
		POI = {},
	}

	return setmetatable(self, Conveyor) :: any
end

function Conveyor.add(self: Types.Conveyor, bag: Types.Bag) end

function Conveyor.remove(self: Types.Conveyor, bag: Types.Bag) end

function Conveyor.update(self: Types.Conveyor) end
