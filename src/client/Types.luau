export type ClientConveyor = {
	Speed: number,
	POI: { [string]: number },
	BagEvents: { [ClientBag]: number },
	Target: ClientContainer,
	Length: number,
	update: (self: ClientConveyor) -> nil,
} & ClientContainer

export type ClientBag = {
	Id: string,
	Color: BrickColor,
	Material: Enum.Material,
	StudsTraversed: number,
	Part: BasePart,
	Initialized: boolean,
	Container: ClientContainer?,
	move: (self: ClientBag, container: ClientContainer) -> nil,

	OriginalSize: Vector3,
	OriginalTransparency: number,

	RotationOffset: number,
	Transparency: number,
	SizeOffset: number,
}

export type ClientContainer = {
	Id: string,
	Part: BasePart,
	Bags: { ClientBag },
	Origin: CFrame,
	addBag: (self: ClientContainer, bag: ClientBag) -> nil,
	removeBag: (self: ClientContainer, bag: ClientBag) -> nil,
	getBagPosition: (self: ClientContainer, bag: ClientBag) -> CFrame,
	loadBags: (self: ClientContainer, bags: { SerializedBag }) -> nil,
}

--I would move these into a shared file for server & client if it was a production program
export type SerializedBag = {
	Id: string,
	Color: BrickColor,
	Material: Enum.Material,
	StudsTraversed: number,
	ContainerId: string,
}

export type SerializedContainer = {
	Type: string,
	Id: string,
	Bags: { SerializedBag },
}

export type SerializedConveyor = {
	Speed: number,
	POI: { [string]: number },
	TargetId: string,
} & SerializedContainer

return {}
