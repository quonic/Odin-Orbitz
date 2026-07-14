package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
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
		// Get the position of the planet on the screen
		planetPosition := raylib.GetWorldToScreen2D(Vector2f64toVector2(Planets[i].Vector), camera)
		// Draw a line from the center of the screen to the planet
		DrawDottedLine(
			planetPosition,
			raylib.Vector2{cast(f32)WindowWidth / 2, cast(f32)WindowHeight / 2},
			10,
			raylib.WHITE,
		)
		// Draw the name of the planet next to the circle
		raylib.DrawTextEx(
			raylib.GetFontDefault(), // Font
			fmt.ctprintf("%v", Planets[i].Name), // Text
			planetPosition, // Position
			18, // Font size
			5, // Spacing
			raylib.GREEN, // Text color
		)
	}

}

draw_dotted_line :: proc(
	from: raylib.Vector2,
	to: raylib.Vector2,
	dot_length: f32,
	color: raylib.Color,
) {
	diff := to - from
	diff_len := linalg.length(diff)
	dir := linalg.normalize(from)
	count := i32(math.ceil(diff_len / dot_length))
	count += count % 2

	points := make([]raylib.Vector2, count)
	defer delete(points)

	for i in 0 ..< count {
		points[i] = from + dir * dot_length * f32(i)
	}
	if (len(points) > 0) {
		raylib.DrawLineStrip(&points[0], i32(len(points)), color)
	}
}

DrawDottedLine :: proc(P0: raylib.Vector2, P1: raylib.Vector2, Step: f32, color: raylib.Color) {
	vector: raylib.Vector2 = P1 - P0
	len: f32 = linalg.length(vector)
	dir := vector * (1.0 / len)
	position: f32 = Step * 0.5

	for (position < len) {
		nextPosition: f32 = position + Step
		if (nextPosition > len) {
			nextPosition = len
		}
		raylib.DrawLineV(P0 + dir * position, P0 + dir * nextPosition, color)
		position = nextPosition + Step
	}
}
