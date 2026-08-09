class_name IsoMath
extends RefCounted
## Matemáticas isométricas 2:1 (tile 64×32).

const TILE_W: int = 64
const TILE_H: int = 32


static func grid_to_screen(grid: Vector2i) -> Vector2:
	return Vector2(
		(grid.x - grid.y) * (TILE_W / 2),
		(grid.x + grid.y) * (TILE_H / 2)
	)


static func screen_to_grid(screen: Vector2) -> Vector2i:
	var a := screen.x / float(TILE_W / 2)
	var b := screen.y / float(TILE_H / 2)
	var x := int(floor((a + b) / 2.0))
	var y := int(floor((b - a) / 2.0))
	return Vector2i(x, y)
