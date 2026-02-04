local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(script.Parent.Parent.Types)
local ClientBag = require(script.Parent.ClientBag)

local ClientContainer = {}
ClientContainer.__index = ClientContainer

function ClientContainer.new(id: string, part: BasePart, bags: { Types.SerializedBag }): Types.ClientContainer
	local self = setmetatable({
		Id = id,
		Part = part,
		Bags = {},
		Origin = part.CFrame * CFrame.new(0, part.Size.Y / 2, 0),
	}, ClientContainer)

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

function ClientContainer.addBag(self: Types.ClientContainer, bag: Types.ClientBag)
	if bag.Container then
		error("Cannot add a bag that already has a container")
	end

	bag.StudsTraversed = 0
	bag.Part.Parent = workspace

	table.insert(self.Bags, bag)
	bag.Container = self

	bag.Part.CFrame = self:getBagPosition(bag)
end

function ClientContainer.removeBag(self: Types.ClientContainer, bag: Types.ClientBag)
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

	if #self.Bags >= i then
		for n = i, #self.Bags do
			self.Bags[n].Part.CFrame = self:getBagPosition(self.Bags[n])
		end
	end
end

function ClientContainer.getBagPosition(self: Types.ClientContainer, bag: Types.ClientBag): CFrame
	local i = table.find(self.Bags, bag)

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
