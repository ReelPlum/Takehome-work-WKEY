export type Bag = {
	Color: BrickColor,
	Material: Enum.Material,
	StudsTraversed: number,
	LastUpdate: number,
	Target: string,
}

export type Conveyor = {
	Bags: { number },
	Speed: number,
	Part: BasePart,
	POI: { [string]: number },
	BagEvents: { [string]: number },
}

return {}
