shader_type canvas_item;
render_mode unshaded;

//uniform sampler2D dispace_x;
//uniform sampler2D dispace_y;
//// Acts as the opaicty
//uniform sampler2D dispace_z;
//
//uniform float mix_float;

uniform sampler2D noise_texture : source_color, repeat_enable;
uniform sampler2D fade ;
instance uniform vec4 color: source_color = vec4(1.0,1.0,1.0,1.0); //
uniform float fade_power : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float strength : hint_range(0.0, 0.05, 0.001) = 0.005;
uniform vec2 speed = vec2(0.1, 0.05);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment() {
	vec2 noise_uv = UV + TIME * speed;
	
	vec2 noice = texture(noise_texture, noise_uv).xy;
	vec2 fades = texture(fade, UV).xy;
	vec2 offset = vec2(noice.x * 2.0 - 1.0, noice.y * 2.0 - 1.0);
	
	offset *= strength * (fades*fade_power);
	vec2 distorted_uv = SCREEN_UV + offset;
	vec2 distorted_uv_color = SCREEN_UV + offset*2.0;
	
	vec4 warp;
	warp.r = texture(SCREEN_TEXTURE, distorted_uv_color).r * (color.r + texture(SCREEN_TEXTURE, distorted_uv_color).r);
	warp.g = texture(SCREEN_TEXTURE, distorted_uv_color).g * (color.g + texture(SCREEN_TEXTURE, distorted_uv_color).g);
	warp.b = texture(SCREEN_TEXTURE, distorted_uv_color).b * (color.b + texture(SCREEN_TEXTURE, distorted_uv_color).b);
	float avr = ((warp.r-texture(fade, UV).r)+(warp.g-texture(fade, UV).g)+(warp.b-texture(fade, UV).b))/3.0;
	warp.a = (warp.r+warp.g+warp.b)/3.0 - avr; // 2.0;
	vec4 final = texture(SCREEN_TEXTURE, distorted_uv);//mix(texture(SCREEN_TEXTURE, distorted_uv),warp,warp.a);
	
	if (final != texture(SCREEN_TEXTURE,SCREEN_UV)) {
		final += (warp*warp.a); 
		COLOR = final;
		}//vec4(color.rgb,texture(fade,UV).r*offset.x),0.05);//vec4(texture(SCREEN_TEXTURE, distorted_uv_color).rgb*vec4(texture(SCREEN_TEXTURE, distorted_uv)+color).rgb,dot(texture(fade,UV).rgb, vec3(0.299, 0.587, 0.114))*fade_power),1.0);
}

