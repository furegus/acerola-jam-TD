// Original by ChaffDave : https://godotshaders.com/shader/tilt-shift-shader/

shader_type canvas_item;

uniform float limit: hint_range(0.0,0.5) = 0.2;
uniform float blur: hint_range(0.0,8.0) = 2.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	float used_limit = limit * limit;
	if (UV.y<used_limit){

		float blur_amount = blur * (1.0 - (SCREEN_UV.y / used_limit));
		COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);

	} else if (UV.y > 1.0-used_limit){

		float blur_amount = blur * (1.0 - ((1.0 - SCREEN_UV.y) / used_limit));
		COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);

	} else {
		COLOR.a = 0.0;
	}
}