export type Conveyor = {
	Speed: number,
	POI: { [string]: number },
	BagEvents: { [Bag]: number },
	Target: Container,
	changeSpeed: (self: Conveyor, speed: number) -> nil,
	serialize: (self: Conveyor) -> SerializedConveyor,
	update: (self: Conveyor) -> nil,
} & Container

export type Bag = {
	Id: string,
	Color: BrickColor,
	Material: Enum.Material,
	StudsTraversed: number,
	LastUpdate: number,
	Container: Container?,
	move: (self: Bag, container: Container) -> nil,
	serialize: (self: Bag) -> SerializedBag,
}

export type Container = {
	Id: string,
	Part: BasePart,
	Bags: { Bag },
	addBag: (self: Container, bag: Bag) -> nil,
	removeBag: (self: Container, bag: Bag) -> nil,
	serialize: (self: Container) -> SerializedContainer,
}

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
