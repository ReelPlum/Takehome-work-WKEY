local Types = require("./Types")

local module = {}

--Calculates how long it will take to reach the end
function module.TimeRemaining(conveyor: Types.Conveyor, traversedStuds: number): number
	local remainingDistance = conveyor.Part.Size.Z - traversedStuds

	return remainingDistance / conveyor.Speed
end

--Calculate how far the bag has travelled since last update
function module.TraversedCalculation(lastUpdate: number, speed: number): number
	return (tick() - lastUpdate) * speed
end

return module
