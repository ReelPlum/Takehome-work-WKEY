local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Types = require(script.Parent.Parent.Types)

local Events = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events")

local ClientBag = {}
ClientBag.__index = ClientBag

function ClientBag.new(
	id: string,
	color: BrickColor,
	material: Enum.Material,
	studsTraversed: number?,
	container: Types.ClientContainer?
): Types.ClientBag
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(3, 1, 4)
	Part.Anchored = true
	Part.CanCollide = false
	Part.BrickColor = color
	Part.Material = material
	Part.Name = id

	local ClickDetector = Instance.new("ClickDetector")
	ClickDetector.Parent = Part
	ClickDetector.MouseClick:Connect(function()
		Events:WaitForChild("PrintID"):FireServer(id)

		warn("Clicked a bag on client: " .. id)
	end)

	if container then
		Part.Parent = Workspace
	else
		Part.Parent = ReplicatedStorage
	end

	local self = setmetatable({
		Id = id,
		Color = color,
		Material = material,
		StudsTraversed = studsTraversed or 0,
		Container = nil,
		Part = Part, --Memory management I'd use something like Maid or Janitor to destroy this part when the bag was cleaned up.
		Initialized = false,

		OriginalSize = Part.Size,
		OriginalTransparency = Part.Transparency,

		RotationOffset = 0,
		Transparency = 0,
		SizeOffset = 0,
	}, ClientBag)

	if container then
		self.Initialized = true
		container:addBag(self)
	end

	return self :: any
end

function ClientBag.move(self: Types.ClientBag, container: Types.ClientContainer)
	if not self.Container then
		error("Cannot move a bag without a container")
	end

	self.Container:removeBag(self)
	container:addBag(self)
end

return ClientBag
