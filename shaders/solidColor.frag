#pragma header

uniform float channel_R;
uniform float channel_G;
uniform float channel_B;

void main() {
    vec3 color = vec3(channel_R, channel_G, channel_B);
    gl_FragColor = vec4(color, flixel_texture2D(bitmap, openfl_TextureSize).a);
}