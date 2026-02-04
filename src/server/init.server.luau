local CollaboratorsService = game:GetService("CollaboratorsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bag = require(script.Modules.Bag)
local Container = require(script.Modules.Container)
local Conveyor = require(script.Modules.Conveyor)
local Types = require(script.Types)

local conveyorSpeed = 25
local maxConveyorSpeed = 50
local minConveyorSpeed = 10

local maxSpawnSpeed = 1.5
local minSpawnSpeed = 0.5
local spawnSpeed = 1

local mainStockpile = Container.new(Workspace.Stockpile)
local mainConveyor = Conveyor.new(workspace.Conveyor, conveyorSpeed, mainStockpile)
local gameOwner = nil

--Tell the clients that mainConveyor & mainStockpile has been created

--Gets sync data used for getting a client up to date when they join
local function getSyncData(): { ["Conveyor"]: Types.SerializedConveyor, ["Stockpile"]: Types.SerializedContainer }
	return {
		Conveyor = mainConveyor:serialize(),
		Stockpile = mainStockpile:serialize(),
	}
end

local Events = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events")

Events:WaitForChild("CreateContainer"):FireAllClients(mainStockpile:serialize())
Events:WaitForChild("CreateConveyor"):FireAllClients(mainConveyor:serialize())

local bagCooldown = spawnSpeed
local lastBagCreation = tick() + bagCooldown
RunService.Heartbeat:Connect(function(a0: number)
	if tick() - lastBagCreation > bagCooldown then
		lastBagCreation = tick()

		local bag = Bag.new()
		mainConveyor:addBag(bag)

		--Tell clients the bag has been created!
		Events:WaitForChild("SpawnBag"):FireAllClients(bag:serialize())
	end

	mainConveyor:update()
end)

Events:WaitForChild("PrintID").OnServerEvent:Connect(function(a0: Player, id)
	warn("A bag was clicked with the id " .. id)
end)

Events:WaitForChild("Ready").OnServerEvent:Connect(function(player: Player)
	warn(player)
	Events:WaitForChild("Sync"):FireClient(player, getSyncData(), gameOwner.UserId)
end)

local function SetGameOwner(player: Player)
	if gameOwner then
		return
	end
	gameOwner = player
	Events:WaitForChild("SetGameOwner"):FireAllClients(player.UserId)

	warn(player)
end

--Check if a player is already in game
if Players:GetPlayers()[1] then
	SetGameOwner(Players:GetPlayers()[1])
end

Players.PlayerAdded:Connect(SetGameOwner)
Players.PlayerRemoving:Connect(function(player: Player)
	if gameOwner == player then
		gameOwner = nil
	end

	if Players:GetPlayers()[1] then
		SetGameOwner(Players:GetPlayers()[1])
	end
end)

local function CreateSpeedAdjuster(instance)
	if not instance:IsA("DragDetector") then
		return
	end
	local totalTranslation = instance.MaxDragTranslation.X - instance.MinDragTranslation.X
	local percentage = (conveyorSpeed - minConveyorSpeed) / (maxConveyorSpeed - minConveyorSpeed)

	instance.DragFrame = CFrame.new(
		Vector3.new(
			totalTranslation * percentage + instance.MinDragTranslation.X,
			instance.ReferenceInstance.Size.Y / 2,
			0
		)
	)

	instance.DragContinue:Connect(function()
		local translation = instance.DragFrame.Position.X
		mainConveyor:changeSpeed(
			(translation - instance.MinDragTranslation.X) / totalTranslation * (maxConveyorSpeed - minConveyorSpeed)
				+ minConveyorSpeed
		)

		for _, i in CollectionService:GetTagged("SpeedAdjuster") do
			if i == instance then
				continue
			end
			--Doesnt support multiple sizes but I dont care rn
			i.DragFrame = instance.DragFrame
		end
	end)
end

for _, instance in CollectionService:GetTagged("SpeedAdjuster") do
	CreateSpeedAdjuster(instance)
end

CollectionService:GetInstanceAddedSignal("SpeedAdjuster"):Connect(CreateSpeedAdjuster)

local function CreateSpawnAdjuster(instance)
	if not instance:IsA("DragDetector") then
		return
	end
	local totalTranslation = instance.MaxDragTranslation.X - instance.MinDragTranslation.X
	local percentage = (spawnSpeed - minSpawnSpeed) / (maxSpawnSpeed - minSpawnSpeed)

	instance.DragFrame = CFrame.new(
		Vector3.new(
			totalTranslation * percentage + instance.MinDragTranslation.X,
			instance.ReferenceInstance.Size.Y / 2,
			0
		)
	)

	instance.PermissionPolicy = Enum.DragDetectorPermissionPolicy.Scriptable
	instance:SetPermissionPolicyFunction(function(player: Player)
		return player == gameOwner
	end)

	instance.DragContinue:Connect(function()
		local translation = instance.DragFrame.Position.X
		bagCooldown = (translation - instance.MinDragTranslation.X) / totalTranslation * (maxSpawnSpeed - minSpawnSpeed)
			+ minSpawnSpeed

		for _, i in CollectionService:GetTagged("SpawnAdjuster") do
			if i == instance then
				continue
			end
			--Doesnt support multiple sizes but I dont care rn
			i.DragFrame = instance.DragFrame
		end
	end)
end

for _, instance in CollectionService:GetTagged("SpawnAdjuster") do
	CreateSpawnAdjuster(instance)
end

CollectionService:GetInstanceAddedSignal("SpawnAdjuster"):Connect(CreateSpeedAdjuster)
