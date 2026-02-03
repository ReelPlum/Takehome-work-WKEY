local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bag = require("./server/Modules/Bag")
local Container = require("./server/Modules/Container")
local Conveyor = require("./server/Modules/Conveyor")
local Types = require("./server/Types")

local mainStockpile = Container.new(Workspace.Stockpile)
local mainConveyor = Conveyor.new(workspace.Conveyor, 10, mainStockpile)

--Gets sync data used for getting a client up to date
local function getSyncData(): { ["Conveyor"]: Types.SerializedConveyor, ["Stockpile"]: Types.SerializedContainer }
	return {
		Conveyor = mainConveyor:serialize(),
		Stockpile = mainStockpile:serialize(),
	}
end

local bagCooldown = 0.25
local lastBagCreation = tick()
RunService.Heartbeat:Connect(function(a0: number)
	if tick() - lastBagCreation > bagCooldown then
		local bag = Bag.new()
		mainConveyor:addBag(bag)

		--Tell clients the bag has been created!
	end
end)
