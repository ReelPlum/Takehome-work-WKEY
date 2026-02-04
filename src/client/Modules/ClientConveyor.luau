local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(script.Parent.Parent.Types)
local ClientBag = require(script.Parent.ClientBag)

local ClientConveyor = {}
ClientConveyor.__index = ClientConveyor

local function FindBagFromId(bags, id)
	for i, v in bags do
		if v.Id == id then
			return i
		end
	end
end

function ClientConveyor.new(
	id: string,
	part: BasePart,
	target: Types.ClientContainer,
	speed: number,
	bags: { Types.SerializedBag }?
): Types.ClientContainer
	local self = setmetatable({
		Id = id,
		Part = part,
		Bags = {},
		POI = {},
		Target = target,
		Length = part.Size.Z,
		Origin = part.CFrame * CFrame.new(0, part.Size.Y / 2, -part.Size.Z / 2),
		Speed = speed,
	}, ClientConveyor)

	self:loadBags(bags)

	return self :: any
end

function ClientConveyor.loadBags(self: Types.ClientConveyor, bags: { Types.SerializedBag })
	if not bags then
		return
	end

	for _, serializedBag in bags do
		if FindBagFromId(self.Bags, serializedBag.Id) then
			continue
		end

		ClientBag.new(serializedBag.Id, serializedBag.Color, serializedBag.Material, serializedBag.StudsTraversed, self)
	end
end

function ClientConveyor.addBag(self: Types.ClientConveyor, bag: Types.ClientBag)
	if bag.Container then
		error("Cannot add a bag that already has a container")
	end

	if FindBagFromId(self.Bags, bag.Id) then
		return
	end

	bag.Part.Parent = workspace

	table.insert(self.Bags, bag)
	bag.Container = self

	local wasInitialized = bag.Initialized
	bag.Initialized = true

	if wasInitialized then
		bag.Part.CFrame = self:getBagPosition(bag)
	else
		--Animation!
		bag.Part.CFrame = self:getBagPosition(bag)
		bag.SizeOffset = math.random(100, 400) / 100
		bag.Transparency = 1
		bag.RotationOffset = math.random(-6500, 6500) / 100
	end
end

function ClientConveyor.removeBag(self: Types.ClientConveyor, bag: Types.ClientBag)
	if not bag.Container then
		error("Cannot remove a bag  that doesnt have a container")
	end

	if bag.Container ~= self then
		error("Cannot remove a bag that has another container")
	end

	local i = FindBagFromId(self.Bags, bag.Id)
	bag.Container = nil
	bag.Part.Parent = ReplicatedStorage
	bag.StudsTraversed = 0

	if i then
		table.remove(self.Bags, i)
	end
end

function ClientConveyor.getBagPosition(self: Types.ClientConveyor, bag: Types.ClientBag): CFrame
	return self.Origin * CFrame.new(0, bag.Part.Size.Y / 2, math.clamp(bag.StudsTraversed, 0, self.Length))
end

function ClientConveyor.update(self: Types.ClientConveyor, dt: number)
	for _, bag in self.Bags do
		bag.StudsTraversed += self.Speed * dt

		if bag.StudsTraversed > self.Length then
			bag:move(self.Target)
			continue
		end

		bag.Part.CFrame = self:getBagPosition(bag) * CFrame.Angles(0, math.rad(bag.RotationOffset), 0)

		bag.Part.Size = bag.OriginalSize + Vector3.new(bag.SizeOffset, bag.SizeOffset, bag.SizeOffset)
		bag.Part.Transparency = bag.Transparency

		bag.Transparency = bag.Transparency + (bag.OriginalTransparency - bag.Transparency) * (5 * dt)
		bag.SizeOffset = bag.SizeOffset + -bag.SizeOffset * (5 * dt)
		bag.RotationOffset = bag.RotationOffset + -bag.RotationOffset * (5 * dt)
	end
end

return ClientConveyor
