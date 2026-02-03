export type ClientConveyor = {
	Speed: number,
	POI: { [string]: number },
	BagEvents: { [ClientBag]: number },
	Target: ClientContainer,
	update: (self: ClientConveyor) -> nil,
} & ClientContainer

export type ClientBag = {
	Id: string,
	Color: BrickColor,
	Material: Enum.Material,
	StudsTraversed: number,
	LastUpdate: number,
	Container: ClientContainer?,
	move: (self: ClientBag, container: ClientContainer) -> nil,
	update: (self: ClientBag) -> nil,
}

export type ClientContainer = {
	Id: string,
	Part: BasePart,
	Bags: { ClientBag },
	addBag: (self: ClientContainer, bag: ClientBag) -> nil,
	removeBag: (self: ClientContainer, bag: ClientBag) -> nil,
	getBagPosition: (self: ClientContainer, bag: ClientBag) -> CFrame,
}

return {}
