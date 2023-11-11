package main
import "core:encoding/csv"
import "core:fmt"
import "core:io"
import "core:math"
import "core:os"
import scon "core:strconv"
import "core:strings"
import "core:time"
import rl "vendor:raylib"

WindowWidth: i32 = 1920
WindowHeight: i32 = 1080
WIDTH :: 1920
HEIGHT :: 1080

Satellite :: struct {
	Name:                string,
	Mass:                f32,
	Diameter:            f32,
	Density:             f32,
	Gravity:             f32,
	EscapeVelocity:      f32,
	RotationPeriod:      f32,
	LengthOfDay:         f32,
	DistanceFromSun:     f32,
	Perihelion:          f32,
	Aphelion:            f32,
	OrbitalPeriod:       f32,
	OrbitalVelocity:     f32,
	OrbitalInclination:  f32,
	OrbitalEccentricity: f32,
	ObliquityToOrbit:    f32,
	Orbiting:            i32,
	Vector:              rl.Vector2,
	Angle:               f32,
	Color:               rl.Color
}


Starting_Zoom: f32 = 100000
Zoom: f32 = 100000
BodyScale: f32 = 2

WindowTitle: cstring : "Odin Orbitz"

Center: rl.Vector2 = {cast(f32)WindowWidth / 2, cast(f32)WindowHeight / 2}

delta: f32
delta_time: f32
TimeMultiplier: f32 = 60
FPS: i32 = 60

LockToPlanet: bool=false
SelectedPlanetIndex:i32 = 0

// Setup our array for the Planets
Planets: [dynamic]Satellite
// Set our "ViewPort" to the center of the screen
ViewPort: rl.Vector2 = Center

main :: proc() {
	// Read our CSV file
	data, ok := os.read_entire_file("planets.csv")
	defer delete(data)
	readCsv: csv.Reader
	ioReader: io.Reader

	// Setup our CSV parser
	csv.reader_init_with_string(&readCsv, transmute(string)data)
	builder := strings.builder_make()

	// Read our header and ignore it
	header, _ := csv.read(&readCsv)
	defer delete(header)

	// Loop to parse each line
	for {
		// Parse new line 
		PlanetData, err := csv.read(&readCsv)

		if (PlanetData == nil) {
			// No more data, break out of look. aka reached the end of the "file"
			break
		}
		if (err != nil) {
			fmt.eprintln(err)
			os.exit(13) // ERROR_INVALID_DATA
		}

		// Converts strings to floats and ints
		mass, _ := scon.parse_f32(PlanetData[1])
		diameter, _ := scon.parse_f32(PlanetData[2])
		density, _ := scon.parse_f32(PlanetData[3])
		gravity, _ := scon.parse_f32(PlanetData[4])
		escapevelocity, _ := scon.parse_f32(PlanetData[5])
		rotationperiod, _ := scon.parse_f32(PlanetData[6])
		lengthofday, _ := scon.parse_f32(PlanetData[7])
		distancefromsun, _ := scon.parse_f32(PlanetData[8])
		perihelion, _ := scon.parse_f32(PlanetData[9])
		aphelion, _ := scon.parse_f32(PlanetData[10])
		orbitalperiod, _ := scon.parse_f32(PlanetData[11])
		orbitalvelocity, _ := scon.parse_f32(PlanetData[12])
		orbitalinclination, _ := scon.parse_f32(PlanetData[13])
		orbitaleccentricity, _ := scon.parse_f32(PlanetData[14])
		obliquitytoorbit, _ := scon.parse_f32(PlanetData[15])
		orbiting, _ := scon.parse_f32(PlanetData[16])
		red,_:=scon.parse_f32(PlanetData[17])
		green,_:=scon.parse_f32(PlanetData[18])
		blue,_:=scon.parse_f32(PlanetData[19])

		// Build our current Planet
		Planet: Satellite = {
			Name = PlanetData[0],
			Mass = mass,
			Diameter = diameter,
			Density = density,
			Gravity = gravity,
			EscapeVelocity = escapevelocity,
			RotationPeriod = rotationperiod,
			LengthOfDay = lengthofday,
			DistanceFromSun = distancefromsun,
			Perihelion = perihelion,
			Aphelion = aphelion,
			OrbitalPeriod = orbitalperiod,
			OrbitalVelocity = orbitalvelocity,
			OrbitalInclination = orbitalinclination,
			OrbitalEccentricity = orbitaleccentricity,
			ObliquityToOrbit = obliquitytoorbit,
			Orbiting = i32(orbiting),
			Vector = {distancefromsun, 0},
			Angle = 0,
			Color=rl.Color{u8(red),u8(green),u8(blue),255}
		}
		// Add our current planet to our Planets array
		append(&Planets, Planet)
	}

	// Our Stopwatch to calculate our time delta
	clock: time.Stopwatch
	time.stopwatch_start(&clock)

	// Start creation of our window
	rl.InitWindow(WIDTH, HEIGHT, WindowTitle)
	// Max FPS
	rl.SetTargetFPS(FPS)
	// Set our window decorations, in this case removes the title bar
	rl.SetWindowState(rl.ConfigFlags{rl.ConfigFlag.WINDOW_UNDECORATED})

	// Can be used to fullscreen window
	// if (!rl.IsWindowFullscreen()) {
	// 	rl.ToggleFullscreen()
	// }

	// Main Game Loop
	for !rl.WindowShouldClose() {
		// Get the frame time from start of loop
		delta = rl.GetFrameTime()
		// Start our drawing
		rl.BeginDrawing()
		// Clear the screen
		rl.ClearBackground(rl.BLACK)

		// Setup our stopwatch for time delta later on
		delta_time = cast(f32)time.duration_seconds(time.stopwatch_duration(clock)) * TimeMultiplier
		time.stopwatch_reset(&clock)
		time.stopwatch_start(&clock)

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
			if(LockToPlanet){
				ViewPort=0-Planets[SelectedPlanetIndex].Vector+Center
			}
			// Draw the planet
			drawPlanet(Planets[i], ViewPort)
		}

		// Draw our "HUD"
		guiY:i32=20
		rl.DrawText(
			fmt.ctprintf("( - / + )Zoom: %v ( [ / ] )Scale: %v", Zoom, BodyScale),
			20,
			guiY,
			20,
			rl.RED,
		)
		guiY+=20
		rl.DrawText(
			fmt.ctprintf("(Left Mouse + Move) Move Around"),
			20,
			guiY,
			20,
			rl.RED,
		)
		guiY+=20
		rl.DrawText(
			fmt.ctprintf("(Right Mouse) Reset Position and Zoom"),
			20,
			guiY,
			20,
			rl.RED,
		)
		guiY+=20
		rl.DrawText(
			fmt.ctprintf("(0-9) Center on Satellites, toggle with (Space Bar)"),
			20,
			guiY,
			20,
			rl.RED,
		)

		// TODO: Move these into checkButtons()
		// Disable Lock to Planet when left mouse is pressed.
		if (rl.IsMouseButtonDown(rl.MouseButton.LEFT)) {
			ViewPort += rl.GetMouseDelta()
			LockToPlanet=false
		}
		// Check our keys
		checkButtons()
		// Reset our view back to Sun and reset zoom to starting zoom
		if (rl.IsMouseButtonPressed(rl.MouseButton.RIGHT)) {
			ViewPort = Center
			Zoom = Starting_Zoom
			LockToPlanet=false
		}
		// End of our drawing
		rl.EndDrawing()
	}
	// Exit application
	rl.CloseWindow()
}


drawPlanet :: proc(b: Satellite, v: rl.Vector2) {
	r: f32 = b.Diameter / 2 / Zoom * BodyScale
	if (r < 1) {r = 1}
	rl.DrawCircle(cast(i32)(b.Vector[0] + v[0]), cast(i32)(b.Vector[1] + v[1]), r, b.Color)

	rl.DrawText(
		fmt.ctprintf("%v", b.Name),
		i32(b.Vector[0] + v[0]+10+r),
		i32(b.Vector[1] + v[1]-10),
		20,
		rl.GREEN,
	)
}

checkButtons :: proc() {
	if(rl.IsKeyPressed(rl.KeyboardKey.SPACE)){
		if(LockToPlanet){
			LockToPlanet=false
		}else{
			LockToPlanet=true
		}
	}
	if(rl.IsKeyDown(rl.KeyboardKey.ZERO)){
		SelectedPlanetIndex=0
	}
	if(rl.IsKeyDown(rl.KeyboardKey.ONE)){
		SelectedPlanetIndex=1
	}
	if(rl.IsKeyDown(rl.KeyboardKey.TWO)){
		SelectedPlanetIndex=2
	}
	if(rl.IsKeyDown(rl.KeyboardKey.THREE)){
		SelectedPlanetIndex=3
	}
	if(rl.IsKeyDown(rl.KeyboardKey.FOUR)){
		SelectedPlanetIndex=5
	}
	if(rl.IsKeyDown(rl.KeyboardKey.FIVE)){
		SelectedPlanetIndex=6
	}
	if(rl.IsKeyDown(rl.KeyboardKey.SIX)){
		SelectedPlanetIndex=7
	}
	if(rl.IsKeyDown(rl.KeyboardKey.SEVEN)){
		SelectedPlanetIndex=8
	}
	if(rl.IsKeyDown(rl.KeyboardKey.EIGHT)){
		SelectedPlanetIndex=9
	}
	if(rl.IsKeyDown(rl.KeyboardKey.NINE)){
		SelectedPlanetIndex=10
	}
	if (rl.IsKeyDown(rl.KeyboardKey.MINUS) || rl.IsKeyDown(rl.KeyboardKey.KP_SUBTRACT) || rl.GetMouseWheelMove() > 0) {
		Zoom += 1000
	}
	if (rl.IsKeyDown(rl.KeyboardKey.EQUAL) || rl.IsKeyDown(rl.KeyboardKey.KP_ADD) || rl.GetMouseWheelMove() < 0) {
		if (Zoom - 1000 < 1000) {
			Zoom = 1000
		} else {
			Zoom -= 1000
		}
	}
	if (rl.IsKeyDown(rl.KeyboardKey.LEFT_BRACKET)) {
		BodyScale += 0.1
		if(BodyScale>6){
			BodyScale=6
		}
	}
	if (rl.IsKeyDown(rl.KeyboardKey.RIGHT_BRACKET)) {
		BodyScale -= 0.1
		if(BodyScale<1){
			BodyScale=1
		}
	}
}

// Unused
angle_between :: proc(p1: rl.Vector2, p2: rl.Vector2) -> f32 {
	return math.atan2(p1[0] - p2[0], p1[1] - p2[1]) * 180 / math.PI
}
