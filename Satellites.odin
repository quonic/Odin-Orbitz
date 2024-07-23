package main

import "core:encoding/csv"
import "core:fmt"
import "core:io"
import "core:math"
import "core:math/linalg"
import "core:os"
import "core:strconv"
import "core:strings"
import "vendor:raylib"

Satellite :: struct {
	Name:                string,
	Mass:                f64,
	Diameter:            f64,
	Density:             f64,
	Gravity:             f64,
	EscapeVelocity:      f64,
	RotationPeriod:      f64,
	LengthOfDay:         f64,
	DistanceFromSun:     f64,
	Perihelion:          f64,
	Aphelion:            f64,
	OrbitalPeriod:       f64,
	OrbitalVelocity:     f64,
	OrbitalInclination:  f64,
	OrbitalEccentricity: f64,
	ObliquityToOrbit:    f64,
	Orbiting:            i32,
	Vector:              linalg.Vector2f64,
	Angle:               f64,
	Color:               raylib.Color,
}

Planets: [dynamic]Satellite

loadPlanets :: proc(path: string) {
	// Read our CSV file
	data, ok := os.read_entire_file(path)
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
		mass, _ := strconv.parse_f64(PlanetData[1])
		diameter, _ := strconv.parse_f64(PlanetData[2])
		density, _ := strconv.parse_f64(PlanetData[3])
		gravity, _ := strconv.parse_f64(PlanetData[4])
		escapevelocity, _ := strconv.parse_f64(PlanetData[5])
		rotationperiod, _ := strconv.parse_f64(PlanetData[6])
		lengthofday, _ := strconv.parse_f64(PlanetData[7])
		distancefromsun, _ := strconv.parse_f64(PlanetData[8])
		perihelion, _ := strconv.parse_f64(PlanetData[9])
		aphelion, _ := strconv.parse_f64(PlanetData[10])
		orbitalperiod, _ := strconv.parse_f64(PlanetData[11])
		orbitalvelocity, _ := strconv.parse_f64(PlanetData[12])
		orbitalinclination, _ := strconv.parse_f64(PlanetData[13])
		orbitaleccentricity, _ := strconv.parse_f64(PlanetData[14])
		obliquitytoorbit, _ := strconv.parse_f64(PlanetData[15])
		orbiting, _ := strconv.parse_f64(PlanetData[16])
		red, _ := strconv.parse_f64(PlanetData[17])
		green, _ := strconv.parse_f64(PlanetData[18])
		blue, _ := strconv.parse_f64(PlanetData[19])

		// Build our current Planet
		Planet: Satellite = {
			Name                = PlanetData[0],
			Mass                = mass,
			Diameter            = diameter,
			Density             = density,
			Gravity             = gravity,
			EscapeVelocity      = escapevelocity,
			RotationPeriod      = rotationperiod,
			LengthOfDay         = lengthofday,
			DistanceFromSun     = distancefromsun,
			Perihelion          = perihelion,
			Aphelion            = aphelion,
			OrbitalPeriod       = orbitalperiod,
			OrbitalVelocity     = orbitalvelocity,
			OrbitalInclination  = orbitalinclination,
			OrbitalEccentricity = orbitaleccentricity,
			ObliquityToOrbit    = obliquitytoorbit,
			Orbiting            = i32(orbiting),
			Vector              = {distancefromsun, 0.0},
			Angle               = 0,
			Color               = raylib.Color{u8(red), u8(green), u8(blue), 255},
		}
		// Add our current planet to our Planets array
		append(&Planets, Planet)
	}
}

drawPlanets :: proc() {
	// Calculate orbits
	for i := 0; i < len(Planets); i += 1 {
		Planets[i].Angle += f64(delta_time) / Planets[i].OrbitalPeriod
		Planets[i].Vector[0] =
			Planets[Planets[i].Orbiting].Vector[0] +
			math.cos_f64(Planets[i].Angle) * Planets[i].DistanceFromSun
		Planets[i].Vector[1] =
			Planets[Planets[i].Orbiting].Vector[1] +
			math.sin(Planets[i].Angle) * Planets[i].DistanceFromSun
		// Draw the planet
		drawPlanet(Planets[i])
	}
}

drawPlanet :: proc(body: Satellite) {
	// Calculate the radius
	r: f32 = f64tof32(body.Diameter) / 2
	// TODO: Add texture dimentions to Satellite struct
	// Textures should be 100x100
	// Calculate the radius, but account for the size of the texture
	radius: f32 = r / (f32(sunTexture.width) / 2)
	// Make sure the radius isn't 0 or less than 0.
	// if (r < 1) {r = 1}
	// Draw the planet
	if (body.Name == "Sun") {
		when ODIN_DEBUG {
			raylib.DrawCircleV(Vector2f64toVector2(body.Vector), r, body.Color)
		}
		raylib.DrawTextureEx(
			sunTexture,
			{
				f64tof32(body.Vector[0]) - radius * f32(sunTexture.width) / 2.0,
				f64tof32(body.Vector[1]) - radius * f32(sunTexture.height) / 2.0,
			},
			0,
			radius,
			raylib.WHITE,
		)
	} else {
		raylib.DrawCircleV(Vector2f64toVector2(body.Vector), r * planet_scale, body.Color)
	}
}
