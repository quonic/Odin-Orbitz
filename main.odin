package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:time"
import "vendor:raylib"

WindowWidth: i32 = 1920
WindowHeight: i32 = 1080

Starting_Zoom: f32 = 100000
Zoom: f32 = 100000
BodyScale: f32 = 2

WindowTitle: cstring : "Odin Orbitz"

delta: f32
delta_time: f32
TimeMultiplier: f32 = 60
FPS: i32 = 60

LockToPlanet: bool = false
SelectedPlanetIndex: i32 = 0

// Textures

sunSprite: raylib.Image
sunTexture: raylib.Texture2D

// Set our Player View Port
PlayerVP := initViewPort(WindowWidth, WindowHeight)

main :: proc() {
	// Setup our array for the Planets
	loadPlanets("planets.csv")

	// Our Stopwatch to calculate our time delta
	clock: time.Stopwatch
	time.stopwatch_start(&clock)

	// Start creation of our window
	raylib.InitWindow(WindowWidth, WindowHeight, WindowTitle)

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
		// Start our drawing
		raylib.BeginDrawing()
		// Clear the screen
		raylib.ClearBackground(raylib.BLACK)

		// Setup our stopwatch for time delta later on
		delta_time =
			cast(f32)time.duration_seconds(time.stopwatch_duration(clock)) * TimeMultiplier
		time.stopwatch_reset(&clock)
		time.stopwatch_start(&clock)

		// Draw our planets
		drawPlanets()
		// Draw our HUD
		drawHud(Zoom, BodyScale)
		// Check our keys
		checkButtons()
		// End of our drawing
		raylib.EndDrawing()
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
			math.cos(Planets[i].Angle) * Planets[i].DistanceFromSun / Zoom / BodyScale
		Planets[i].Vector[1] =
			Planets[Planets[i].Orbiting].Vector[1] +
			math.sin(Planets[i].Angle) * Planets[i].DistanceFromSun / Zoom / BodyScale
		// Lock view to a planet
		if (LockToPlanet) {
			PlayerVP.Position = 0 - Planets[SelectedPlanetIndex].Vector + PlayerVP.Center
		}
		// Draw the planet
		drawPlanet(Planets[i], PlayerVP.Position)
	}
}

drawPlanet :: proc(body: Satellite, vector: raylib.Vector2) {
	// Calculate the radius, accounting for Zoom and BodyScale
	r: f32 = body.Diameter / 2 / Zoom * BodyScale
	// TODO: Add texture dimentions to Satellite struct
	// Textures should be 100x100
	// Calculate the radius, but account for the size of the texture
	radius: f32 = r / (f32(sunTexture.width) / 2)
	// Make sure the radius isn't 0 or less than 0.
	// if (r < 1) {r = 1}
	// Draw the planet
	if (body.Name == "Sun") {
		when ODIN_DEBUG {
			raylib.DrawCircle(
				cast(i32)(body.Vector[0] + vector[0]),
				cast(i32)(body.Vector[1] + vector[1]),
				r,
				body.Color,
			)
		}
		raylib.DrawTextureEx(
			sunTexture,
			{
				body.Vector[0] + vector[0] - radius * f32(sunTexture.width) / 2,
				body.Vector[1] + vector[1] - radius * f32(sunTexture.height) / 2,
			},
			0,
			radius,
			raylib.WHITE,
		)
	} else {
		raylib.DrawCircle(
			cast(i32)(body.Vector[0] + vector[0]),
			cast(i32)(body.Vector[1] + vector[1]),
			r,
			body.Color,
		)
	}

	// Draw the name of the planet next to the circle
	raylib.DrawText(
		fmt.ctprintf("%v", body.Name),
		i32(body.Vector[0] + vector[0] + 10 + r),
		i32(body.Vector[1] + vector[1] - 10),
		20,
		raylib.GREEN,
	)
}

checkButtons :: proc() {
	// Disable Lock to Planet when left mouse is pressed.
	if (raylib.IsMouseButtonDown(raylib.MouseButton.LEFT)) {
		PlayerVP.Position += raylib.GetMouseDelta()
		LockToPlanet = false
	}
	if (raylib.IsKeyPressed(raylib.KeyboardKey.SPACE)) {
		if (LockToPlanet) {
			LockToPlanet = false
		} else {
			LockToPlanet = true
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
	if (raylib.IsKeyDown(raylib.KeyboardKey.MINUS) ||
		   raylib.IsKeyDown(raylib.KeyboardKey.KP_SUBTRACT) ||
		   raylib.GetMouseWheelMove() > 0) {
		Zoom += 1000
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.EQUAL) ||
		   raylib.IsKeyDown(raylib.KeyboardKey.KP_ADD) ||
		   raylib.GetMouseWheelMove() < 0) {
		if (Zoom - 1000 < 1000) {
			Zoom = 1000
		} else {
			Zoom -= 1000
		}
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.LEFT_BRACKET)) {
		BodyScale += 0.1
		if (BodyScale > 6) {
			BodyScale = 6
		}
	}
	if (raylib.IsKeyDown(raylib.KeyboardKey.RIGHT_BRACKET)) {
		BodyScale -= 0.1
		if (BodyScale < 1) {
			BodyScale = 1
		}
	}
	// Reset our view back to Sun and reset zoom to starting zoom
	if (raylib.IsMouseButtonPressed(raylib.MouseButton.RIGHT)) {
		PlayerVP.Position = PlayerVP.Center
		Zoom = Starting_Zoom
		LockToPlanet = false
	}
}

// Unused
angle_between :: proc(p1: raylib.Vector2, p2: raylib.Vector2) -> f32 {
	return math.atan2(p1[0] - p2[0], p1[1] - p2[1]) * 180 / math.PI
}
