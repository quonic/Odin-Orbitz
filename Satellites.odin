package main

import "core:encoding/csv"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strconv"
import "core:strings"
import "vendor:raylib"

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
	Vector:              raylib.Vector2,
	Angle:               f32,
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
		mass, _ := strconv.parse_f32(PlanetData[1])
		diameter, _ := strconv.parse_f32(PlanetData[2])
		density, _ := strconv.parse_f32(PlanetData[3])
		gravity, _ := strconv.parse_f32(PlanetData[4])
		escapevelocity, _ := strconv.parse_f32(PlanetData[5])
		rotationperiod, _ := strconv.parse_f32(PlanetData[6])
		lengthofday, _ := strconv.parse_f32(PlanetData[7])
		distancefromsun, _ := strconv.parse_f32(PlanetData[8])
		perihelion, _ := strconv.parse_f32(PlanetData[9])
		aphelion, _ := strconv.parse_f32(PlanetData[10])
		orbitalperiod, _ := strconv.parse_f32(PlanetData[11])
		orbitalvelocity, _ := strconv.parse_f32(PlanetData[12])
		orbitalinclination, _ := strconv.parse_f32(PlanetData[13])
		orbitaleccentricity, _ := strconv.parse_f32(PlanetData[14])
		obliquitytoorbit, _ := strconv.parse_f32(PlanetData[15])
		orbiting, _ := strconv.parse_f32(PlanetData[16])
		red, _ := strconv.parse_f32(PlanetData[17])
		green, _ := strconv.parse_f32(PlanetData[18])
		blue, _ := strconv.parse_f32(PlanetData[19])

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
			Color = raylib.Color{u8(red), u8(green), u8(blue), 255},
		}
		// Add our current planet to our Planets array
		append(&Planets, Planet)
	}
}
