package main

import "core:fmt"
import "vendor:raylib"

drawHud :: proc(zoom: f32, bodyScale: f32) {
	// Draw our "HUD"
	guiY: i32 = 20
	raylib.DrawText(
		fmt.ctprintf("( - / + )Zoom: %v ( [ / ] )Scale: %v", zoom, bodyScale),
		20,
		guiY,
		20,
		raylib.RED,
	)
	guiY += 20
	raylib.DrawText(fmt.ctprintf("(Left Mouse + Move) Move Around"), 20, guiY, 20, raylib.RED)
	guiY += 20
	raylib.DrawText(
		fmt.ctprintf("(Right Mouse) Reset Position and Zoom"),
		20,
		guiY,
		20,
		raylib.RED,
	)
	guiY += 20
	raylib.DrawText(
		fmt.ctprintf("(0-9) Center on Satellites, toggle with (Space Bar)"),
		20,
		guiY,
		20,
		raylib.RED,
	)
}
