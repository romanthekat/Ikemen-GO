uniform sampler2D tex;
uniform sampler2D pal;

uniform vec4 x1x2x4x3;
uniform vec3 add, mul;
uniform float alpha, gray;
uniform int mask;
uniform bool isRgba, isTrapez, neg;

varying vec2 texcoord;

void main(void) {
	vec2 uv = texcoord;
	if (isTrapez) {
		// Compute left/right trapezoid bounds at height uv.y
		vec2 bounds = mix(x1x2x4x3.zw, x1x2x4x3.xy, uv.y);
		// Correct uv.x from the fragment position on that segment
		uv.x = (gl_FragCoord.x - bounds[0]) / (bounds[1] - bounds[0]);
	}
	vec4 c = texture2D(tex, uv);
	vec3 neg_base = vec3(1.0);
	vec3 final_add = add;
	vec4 final_mul = vec4(mul, alpha);
	if (isRgba) {
		// RGBA sprites use premultiplied alpha for transparency
		neg_base *= alpha;
		final_add *= c.a;
		final_mul.rgb *= alpha;
	} else {
		// Colormap sprites use the old “buggy” Mugen way
		if (int(255.25*c.r) == mask) {
			final_mul = vec4(0.0);
		} else {
			c = texture2D(pal, vec2(c.r*0.9966, 0.5));
		}
	}
	if (neg) c.rgb = neg_base - c.rgb;
	c.rgb = mix(c.rgb, vec3((c.r + c.g + c.b) / 3.0), gray) + final_add;
	gl_FragColor = c * final_mul;
}
