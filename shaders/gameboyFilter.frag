#pragma header

vec3 palette[4] = vec3[](
    vec3(0.1, 0.3, 0.1),
    vec3(0.2, 0.5, 0.2),
    vec3(0.6, 0.8, 0.3),
    vec3(0.8, 1.0, 0.4)
);

void main() {
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 uv = fragCoord / openfl_TextureSize.xy;

    vec4 color = flixel_texture2D(bitmap, uv);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114)); // converts to grayscale
    int paletteIndex = int(gray * 3.0); // maps to palette index
    gl_FragColor = vec4(palette[paletteIndex], color.a);
}