package main

import "vendor:raylib"

ViewPort :: struct {
	Position: raylib.Vector2,
	Center:   raylib.Vector2,
}

initViewPort :: proc(Width: i32, Height: i32) -> ViewPort {
	return(
		{
			Position = {cast(f32)Width / 2, cast(f32)Height / 2},
			Center = {cast(f32)Width / 2, cast(f32)Height / 2},
		}
	)
}
