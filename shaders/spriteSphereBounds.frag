#pragma header

uniform float uRadius;
uniform vec2 uCenter;

float distance2D(vec2 a, vec2 b) {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
}

void main() {
    vec2 uv = (openfl_TextureCoordv * openfl_TextureSize) / openfl_TextureSize;
    vec2 center = uCenter / openfl_TextureSize;
    float dist = distance2D(uv, center);

    if (dist < uRadius) {
        gl_FragColor = flixel_texture2D(bitmap, uv);
    } else {
        discard;
    }
}