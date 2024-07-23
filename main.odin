package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:time"
import "vendor:raylib"

WindowWidth: i32 = 1920
WindowHeight: i32 = 1080

Starting_Zoom: f32 = 0.0001

WindowTitle: cstring : "Odin Orbitz"

delta: f32
delta_time: f32
TimeMultiplier: f32 = 60
FPS: i32 = 60

LockToPlanet: bool = false
SelectedPlanetIndex: i32 = 0

planet_scale: f32 = 10

// Textures

sunSprite: raylib.Image
sunTexture: raylib.Texture2D

// Camera
cameraOffset := raylib.Vector2{cast(f32)WindowWidth / 2, cast(f32)WindowHeight / 2}
cameraTarget := raylib.Vector2{0, 0}
cameraRotation: f32 = 0
cameraZoom: f32 = 0.0001
camera: raylib.Camera2D

main :: proc() {
	// Setup our array for the Planets
	loadPlanets("planets.csv")

	// Our Stopwatch to calculate our time delta
	clock: time.Stopwatch
	time.stopwatch_start(&clock)

	// Start creation of our window
	raylib.InitWindow(WindowWidth, WindowHeight, WindowTitle)
	SetWindowToCenterMonitor()

	// Set our camera
	camera.offset = cameraOffset
	camera.target = cameraTarget
	camera.rotation = cameraRotation
	camera.zoom = cameraZoom

	// Must load textures after InitWindow
	sunSprite = raylib.LoadImage("./sprites/Sun.png")
	sunTexture = raylib.LoadTextureFromImage(sunSprite)
	// Max FPS
	raylib.SetTargetFPS(FPS)
	// Set our window decorations, in this case removes the title bar
	raylib.SetWindowState(raylib.ConfigFlags{raylib.ConfigFlag.WINDOW_UNDECORATED})

	// Can be used to fullscreen window
	// if (!raylib.IsWindowFullscreen()) {
	// 	raylib.ToggleFullscreen()
	// }

	// Main Game Loop
	for !raylib.WindowShouldClose() {
		// Get the frame time from start of loop
		delta = raylib.GetFrameTime()
		{
			// Start our drawing
			raylib.BeginDrawing()
			defer raylib.EndDrawing()
			// Clear the screen
			raylib.ClearBackground(raylib.BLACK)

			// Setup our stopwatch for time delta later on
			delta_time =
				cast(f32)time.duration_seconds(time.stopwatch_duration(clock)) * TimeMultiplier
			time.stopwatch_reset(&clock)
			time.stopwatch_start(&clock)

			{
				raylib.BeginMode2D(camera)
				defer raylib.EndMode2D()

				// Lock view to a planet
				if (LockToPlanet) {
					camera.target = Planets[SelectedPlanetIndex].Vector
				}

				// Draw our planets
				drawPlanets()
			}
			// Draw our HUD
			drawHud()
			// Check our keys
			checkButtons()
		}
	}
	// Exit application
	raylib.CloseWindow()
}

drawPlanets :: proc() {
	// Calculate orbits
	for i := 0; i < len(Planets); i += 1 {
		Planets[i].Angle += delta_time / Planets[i].OrbitalPeriod
		Planets[i].Vector[0] =
			Planets[Planets[i].Orbiting].Vector[0] +
			math.cos(Planets[i].Angle) * Planets[i].DistanceFromSun
		Planets[i].Vector[1] =
			Planets[Planets[i].Orbiting].Vector[1] +
			math.sin(Planets[i].Angle) * Planets[i].DistanceFromSun
		// Draw the planet
		drawPlanet(Planets[i])
	}
}

drawPlanet :: proc(body: Satellite) {
	// Calculate the radius
	r: f32 = body.Diameter / 2
	// TODO: Add texture dimentions to Satellite struct
	// Textures should be 100x100
	// Calculate the radius, but account for the size of the texture
	radius: f32 = r / (f32(sunTexture.width) / 2)
	// Make sure the radius isn't 0 or less than 0.
	// if (r < 1) {r = 1}
	// Draw the planet
	if (body.Name == "Sun") {
		when ODIN_DEBUG {
			raylib.DrawCircleV(body.Vector, r, body.Color)
		}
		raylib.DrawTextureEx(
			sunTexture,
			{
				body.Vector[0] - radius * f32(sunTexture.width) / 2,
				body.Vector[1] - radius * f32(sunTexture.height) / 2,
			},
			0,
			radius,
			raylib.WHITE,
		)
	} else {
		raylib.DrawCircleV(body.Vector, r * planet_scale, body.Color)
	}
}

checkButtons :: proc() {
	if (raylib.IsKeyPressed(raylib.KeyboardKey.SPACE)) {
		if (LockToPlanet) {
			LockToPlanet = false
			camera.target = Planets[SelectedPlanetIndex].Vector
		} else {
			LockToPlanet = true
			camera.target = Planets[SelectedPlanetIndex].Vector
		}
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.ZERO)) {
		SelectedPlanetIndex = 0
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.ONE)) {
		SelectedPlanetIndex = 1
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.TWO)) {
		SelectedPlanetIndex = 2
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.THREE)) {
		SelectedPlanetIndex = 3
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.FOUR)) {
		SelectedPlanetIndex = 5
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.FIVE)) {
		SelectedPlanetIndex = 6
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.SIX)) {
		SelectedPlanetIndex = 7
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.SEVEN)) {
		SelectedPlanetIndex = 8
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.EIGHT)) {
		SelectedPlanetIndex = 9
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.NINE)) {
		SelectedPlanetIndex = 10
	}

	// Translate based on mouse right click
	if (!LockToPlanet && raylib.IsMouseButtonDown(raylib.MouseButton.RIGHT)) {
		deltaMouse: raylib.Vector2 = raylib.GetMouseDelta()
		deltaMouse = deltaMouse * (-1.0 / camera.zoom)
		camera.target = camera.target + deltaMouse
	}
	// Zoom based on mouse wheel

	wheel := raylib.GetMouseWheelMove()
	if (wheel != 0) {
		if (!LockToPlanet) {
			// Get the world point that is under the mouse
			mouseWorldPos := raylib.GetScreenToWorld2D(raylib.GetMousePosition(), camera)

			// Set the offset to where the mouse is
			camera.offset = raylib.GetMousePosition()

			// Set the target to match, so that the camera maps the world space point 
			// under the cursor to the screen space point under the cursor at any zoom
			camera.target = mouseWorldPos
		}
		// Zoom increment
		scaleFactor: f32 = 1.0 + (0.25 * abs(wheel))
		if (wheel < 0) {scaleFactor = 1.0 / scaleFactor}
		camera.zoom = raylib.Clamp(camera.zoom * scaleFactor, 0.0000001, 1)
	}

}

// Unused
angle_between :: proc(p1: raylib.Vector2, p2: raylib.Vector2) -> f32 {
	return math.atan2(p1[0] - p2[0], p1[1] - p2[1]) * 180 / math.PI
}
