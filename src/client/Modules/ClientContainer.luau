local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)
local ClientBag = require(script.Parent.ClientBag)

local ClientContainer = {}
ClientContainer.__index = ClientContainer

local function FindBagFromId(bags, id)
	for i, v in bags do
		if v.Id == id then
			return i
		end
	end
end

function ClientContainer.new(id: string, part: BasePart, bags: { Types.SerializedBag }?): Types.ClientContainer
	local self = setmetatable({
		Id = id,
		Part = part,
		Bags = {},
		Origin = part.CFrame * CFrame.new(0, part.Size.Y / 2, 0),
	}, ClientContainer)

	self:loadBags(bags)

	return self :: any
end

function ClientContainer.loadBags(self: Types.ClientContainer, bags: { Types.SerializedBag })
	if not bags then
		return
	end

	warn(bags)
	for _, serializedBag in bags do
		if FindBagFromId(self.Bags, serializedBag.Id) then
			continue
		end
		ClientBag.new(serializedBag.Id, serializedBag.Color, serializedBag.Material, serializedBag.StudsTraversed, self)
	end
	warn(self.Bags)
end

function ClientContainer.addBag(self: Types.ClientContainer, bag: Types.ClientBag)
	if bag.Container then
		error("Cannot add a bag that already has a container")
	end

	if FindBagFromId(self.Bags, bag.Id) then
		return
	end

	table.insert(self.Bags, bag)

	bag.Part.Parent = workspace

	bag.Container = self

	local wasInitialized = bag.Initialized
	bag.Initialized = true

	if not wasInitialized then
		bag.Part.CFrame = self:getBagPosition(bag)
	else
		--Animation!
		--bag.Part.CFrame = self:getBagPosition(bag)

		local cf = self:getBagPosition(bag)
		local target = cf.Position
		local targetDirection = cf.lookVector
		local currentDirection = bag.Part.CFrame.lookVector
		--Bezier curve

		local p0 = bag.Part.CFrame.Position
		local p1 = p0:lerp(target, 0.5)
			+ Vector3.new(math.random(-1500, 1500) / 100, math.random(100, 1500) / 100, math.random(-1500, 1500) / 100)

		local conn = nil
		local start = tick()
		local tweenTime = 1.25

		conn = RunService.RenderStepped:Connect(function(dt: number)
			local i = (tick() - start) / tweenTime
			local t = TweenService:GetValue(i, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

			bag.Part.CFrame = CFrame.lookAlong(
				(1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * target,
				currentDirection:lerp(targetDirection, t)
			)

			if i >= 1 then
				bag.Part.CFrame = cf
				conn:Disconnect()
			end
		end)
	end
end

function ClientContainer.removeBag(self: Types.ClientContainer, bag: Types.ClientBag)
	if not bag.Container then
		error("Cannot remove a bag  that doesnt have a container")
	end

	if bag.Container ~= self then
		error("Cannot remove a bag that has another container")
	end

	local i = FindBagFromId(self.Bags, bag.Id)
	bag.Container = nil
	bag.Part.Parent = ReplicatedStorage

	if i then
		table.remove(self.Bags, i)
	end

	if #self.Bags >= i then
		for n = i, #self.Bags do
			self.Bags[n].Part.CFrame = self:getBagPosition(self.Bags[n])
		end
	end
end

function ClientContainer.getBagPosition(self: Types.ClientContainer, bag: Types.ClientBag): CFrame
	local i = FindBagFromId(self.Bags, bag.Id)

	--I could also make it automatically detect how many rows & columns there could be to fit bags, but I'm just gonna hardcode it lol
	local rows = 5
	local columns = 5

	local x, y, z = (i - 1) % columns, math.floor((i - 1) / columns) % rows, math.floor((i - 1) / (rows * columns))

	return self.Origin
		* CFrame.new(
			-bag.Part.Size.X * math.floor(columns / 2),
			bag.Part.Size.Y / 2,
			-bag.Part.Size.Z * math.floor(rows / 2)
		)
		* CFrame.new(x * bag.Part.Size.X, z * bag.Part.Size.Y, y * bag.Part.Size.Z)
end

return ClientContainer
