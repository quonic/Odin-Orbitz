package main

import "core:math/linalg"
import "vendor:raylib"

scale32: f32 = 1024 * 2
scale64: f64 = 1024 * 2

// Scale a float64 to a float32 so that the maximum value of a float64 can be represented by a float32
Vector2f64toVector2 :: proc(value: linalg.Vector2f64) -> raylib.Vector2 {
	return raylib.Vector2{cast(f32)(value[0] / scale64), cast(f32)(value[1] / scale64)}
}

Vector2toVector2f64 :: proc(value: raylib.Vector2) -> linalg.Vector2f64 {
	return linalg.Vector2f64{cast(f64)(value[0] * scale32), cast(f64)(value[1] * scale32)}
}

f64tof32 :: proc(value: f64) -> f32 {
	return cast(f32)(value / scale64)
}

f32tof64 :: proc(value: f32) -> f64 {
	return cast(f64)(value * scale32)
}
