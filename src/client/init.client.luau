local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Create these when the server tells the client to. We could also just create them ourselves on the client, but we're going to listen to the server instead, because speed etc. is set on the server. In a tycoon etc. speed would be set as an attribute on the part and we could in that case create these on the client without waiting for the server.
local ClientConveyor = require(script.Modules.ClientConveyor)
local ClientBag = require(script.Modules.ClientBag)
local ClientContainer = require(script.Modules.ClientContainer)
local Types = require(script.Types)

local Conveyors = {}
local Stockpiles = {}

RunService.RenderStepped:Connect(function(dt: number)
	--Update all bags and their position. We're going to simulate everything on the client. The server only tells the client when a bag is created & if a bag for some reason is removed mid run. With further expansion the server could also tell the client things like clearing stockpiles etc.
	for _, conveyor in Conveyors do
		conveyor:update(dt)
	end
end)

local function SetGameOwner(isGameOwner)
	if not isGameOwner then
		--Make all SpawnAdjusters red.
		for _, i in CollectionService:GetTagged("SpawnAdjuster") do
			i.Parent.BrickColor = BrickColor.Red()
			i.Parent.Material = Enum.Material.SmoothPlastic
		end

		return
	end

	--Is game owner
	for _, i in CollectionService:GetTagged("SpawnAdjuster") do
		i.Parent.BrickColor = BrickColor.Green()
		i.Parent.Material = Enum.Material.Neon
	end
end

--Listen for server events. I'd usually use something like Comms by Sleitnick for communication, but today I'm just gonna use default Remove Events
local Events = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events")

Events:WaitForChild("Sync").OnClientEvent:Connect(
	function(
		syncData: { ["Conveyor"]: Types.SerializedConveyor, ["Stockpile"]: Types.SerializedContainer },
		gameOwnerUserId: number
	)
		--Would do this differently if support for multiple conveyors etc. were to be added
		print(syncData)
		if not Stockpiles[syncData.Stockpile.Id] then
			Stockpiles[syncData.Stockpile.Id] = ClientContainer.new(
				syncData.Stockpile.Id,
				workspace:WaitForChild(syncData.Stockpile.Id),
				syncData.Stockpile.Bags
			)
		else
			Stockpiles[syncData.Stockpile.Id]:loadBags(syncData.Stockpile.Bags)
		end

		if not Conveyors[syncData.Conveyor.Id] then
			Conveyors[syncData.Conveyor.Id] = ClientConveyor.new(
				syncData.Conveyor.Id,
				workspace:WaitForChild(syncData.Conveyor.Id),
				Stockpiles[syncData.Conveyor.TargetId],
				syncData.Conveyor.Speed,
				syncData.Conveyor.Bags
			)
		else
			Conveyors[syncData.Stockpile.Id]:loadBags(syncData.Conveyor.Bags)
		end

		SetGameOwner(gameOwnerUserId == Players.LocalPlayer.UserId)
	end
)

Events:WaitForChild("SpawnBag").OnClientEvent:Connect(function(data: Types.SerializedBag)
	local container = Conveyors[data.ContainerId]
	if not container then
		container = Stockpiles[data.ContainerId]
	end

	if not container then
		return
	end

	ClientBag.new(data.Id, data.Color, data.Material, data.StudsTraversed, container)
end)

Events:WaitForChild("CreateConveyor").OnClientEvent:Connect(function(data: Types.SerializedConveyor)
	if not Conveyors[data.Id] then
		Conveyors[data.Id] =
			ClientConveyor.new(data.Id, workspace[data.Id], Stockpiles[data.TargetId], data.Speed, data.Bags)
	end
end)

Events:WaitForChild("CreateContainer").OnClientEvent:Connect(function(data: Types.SerializedContainer)
	if not Stockpiles[data.Id] then
		Stockpiles[data.Id] = ClientContainer.new(data.Id, workspace[data.Id], data.Bags)
	end
end)

Events:WaitForChild("SetConveyorSpeed").OnClientEvent:Connect(function(conveyorId: string, speed: number)
	if not Conveyors[conveyorId] then
		return
	end

	Conveyors[conveyorId].Speed = speed
end)

Events:WaitForChild("SetGameOwner").OnClientEvent:Connect(function(gameOwnerUserId: number)
	SetGameOwner(gameOwnerUserId == Players.LocalPlayer.UserId)
end)

repeat
	task.wait()
until game:IsLoaded()
task.wait(0.25)
Events:WaitForChild("Ready"):FireServer()
