local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(script.Parent.Parent.Types)
local ClientBag = require(script.Parent.ClientBag)

local ClientConveyor = {}
ClientConveyor.__index = ClientConveyor

function ClientConveyor.new(
	id: string,
	part: BasePart,
	target: Types.ClientContainer,
	speed: number,
	bags: { Types.SerializedBag }
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

	for _, serializedBag in bags do
		local createdBag = ClientBag.new(
			serializedBag.Id,
			serializedBag.Color,
			serializedBag.Material,
			serializedBag.StudsTraversed,
			self
		)
		table.insert(self.Bags, createdBag)

		--Position bag
		createdBag.Part.CFrame = self:getBagPosition(createdBag)
	end

	return self :: any
end

function ClientConveyor.addBag(self: Types.ClientConveyor, bag: Types.ClientBag)
	if bag.Container then
		error("Cannot add a bag that already has a container")
	end

	bag.StudsTraversed = 0
	bag.Part.CFrame = self:getBagPosition(bag)
	bag.Part.Parent = workspace

	table.insert(self.Bags, bag)
	bag.Container = self
end

function ClientConveyor.removeBag(self: Types.ClientConveyor, bag: Types.ClientBag)
	if not bag.Container then
		error("Cannot remove a bag  that doesnt have a container")
	end

	if bag.Container ~= self then
		error("Cannot remove a bag that has another container")
	end

	local i = table.find(self.Bags, bag)
	bag.Container = nil
	bag.Part.Parent = ReplicatedStorage

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

		bag.Part.CFrame = self:getBagPosition(bag)
	end
end

return ClientConveyor
