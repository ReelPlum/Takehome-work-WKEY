export type Conveyor = {
	Speed: number,
	POI: { [string]: number },
	BagEvents: { [string]: number },
} & Container

export type Bag = {
	Id: string,
	Color: BrickColor,
	Material: Enum.Material,
	StudsTraversed: number,
	LastUpdate: number,
	Target: string,
	Container: Container?,
	move: (self: Bag, container: Container) -> nil,
}

export type Container = {
	Part: BasePart,
	Bags: { string },
	addBag: (self: Container, bag: Bag) -> nil,
	removeBag: (self: Container, bag: Bag) -> nil,
}

return {}
