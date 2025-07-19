module main

fn clamp[T](value T, min T, max T) T {
	if value < min { return min }
	if value > max { return max }
	return value
}

fn lerp[T](a T, b T, t T ) T  { return a + ((b - a) * t) }

fn lerp_f1[T, F](a T, b T, t F ) T  { return T(F(a) + ((F(b) - F(a)) * t)) }

fn invlerp[T](v T, a T, b T) T { return ( v - a ) / ( b - a ) }

fn invlerp_f1[T, F](v F, a T, b T) F { return ( F(v) - F(a) ) / ( F(b) - F(a) ) }