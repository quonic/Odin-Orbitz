package main

import "core:fmt"
import "vendor:raylib"

drawHud :: proc() {
	// Draw our "HUD"
	guiY: i32 = 20
	raylib.DrawText(fmt.ctprintf("Zoom Level: %v", camera.zoom), 20, guiY, 20, raylib.RED)
	guiY += 20
	raylib.DrawText(fmt.ctprintf("Right Mouse to Move Around"), 20, guiY, 20, raylib.RED)
	guiY += 20
	raylib.DrawText(fmt.ctprintf("Scroll to Zoom"), 20, guiY, 20, raylib.RED)
	guiY += 20
	raylib.DrawText(
		fmt.ctprintf("(0-9) Center on Satellites, toggle with (Space Bar)"),
		20,
		guiY,
		20,
		raylib.RED,
	)

	// Draw the name of the planet next to the circle
	for i := 0; i < len(Planets); i += 1 {
		// Draw the name of the planet next to the circle
		raylib.DrawTextEx(
			raylib.GetFontDefault(), // Font
			fmt.ctprintf("%v", Planets[i].Name), // Text
			raylib.GetWorldToScreen2D(Vector2f64toVector2(Planets[i].Vector), camera), // Position
			18, // Font size
			5, // Spacing
			raylib.GREEN, // Text color
		)
	}

}
