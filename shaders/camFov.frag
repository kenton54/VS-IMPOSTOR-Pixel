#pragma header
#define PI 3.14159265359

int steps = 1;
int stepsInside = 1;
float strength = 0.08;

uniform sampler2D titulo;
uniform float tituloX;
vec4 invertTitle(vec4 color) {
	vec2 pos = openfl_TextureCoordv;
	pos.x -= tituloX;
	pos.y -= 0.5;
	pos.y *= 4.0;
	pos.y += 0.5+sin(openfl_TextureCoordv.x*20.0)*0.1;
	return vec4(abs(flixel_texture2D(titulo,pos).r-color.rgb),1.0);
}

uniform float horIntensity; // default is 1.0
uniform float verIntensity; // default is 0.5625
uniform float rotation;
uniform float res;

void main() {
	vec2 pos = openfl_TextureCoordv;
	pos -= 0.5;
	float xx = abs(cos(pos.x*horIntensity));
	float yy = abs(cos(pos.y*verIntensity));
	pos *= xx*yy;

	float coseno;float seno;
	float rta = pos.x*rotation;
	if(pos.x >= 0) {
		coseno = cos(rta);
		seno = sin(rta);
	}
	else {
		coseno = cos(-rta);
		seno = sin(-rta);
	}
	vec2 camPos = pos;
	pos.x = camPos.x*coseno-camPos.y*seno;
	pos.y = camPos.x*seno+camPos.y*coseno;

	pos *= 1.0-res;

	pos += 0.5;

	camPos = pos;
	vec3 col = flixel_texture2D(bitmap, camPos).rgb;

	vec4 color = flixel_texture2D(bitmap,camPos);
	float fsteps = 1.0;
	for(float inside = 1.0; inside < 2.0; inside++) {
		for(int i = 0; i < 1; i++) {
			float fi = float(i);
			color += flixel_texture2D(bitmap,camPos + vec2(
				strength * (inside / 1.0) * cos(fi / fsteps * (PI * 2.0)),
				strength * (inside / 1.0) * sin(fi / fsteps * (PI * 2.0))
			));
		}
	}

	gl_FragColor = invertTitle(vec4(col+color.rgb*0.0-res,1.0));
}