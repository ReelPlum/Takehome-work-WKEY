local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bag = require(script.Modules.Bag)
local Container = require(script.Modules.Container)
local Conveyor = require(script.Modules.Conveyor)
local Types = require(script.Types)

local mainStockpile = Container.new(Workspace.Stockpile)
local mainConveyor = Conveyor.new(workspace.Conveyor, 25, mainStockpile)
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

local bagCooldown = 0.25
local lastBagCreation = tick() + bagCooldown
RunService.Heartbeat:Connect(function(a0: number)
	if tick() - lastBagCreation > bagCooldown then
		lastBagCreation = tick()

		local bag = Bag.new()
		mainConveyor:addBag(bag)

		--Tell clients the bag has been created!
		Events:WaitForChild("SpawnBag"):FireAllClients(bag:serialize())
	end
end)

Events:WaitForChild("Ready").OnServerEvent:Connect(function(player: Player)
	Events:WaitForChild("Sync"):FireClient(player, getSyncData(), gameOwner == player)
end)

local function SetGameOwner(player: Player)
	if gameOwner then
		return
	end
	gameOwner = player
	Events:WaitForChild("SetGameOwner"):FireAllClients(player.UserId)
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
