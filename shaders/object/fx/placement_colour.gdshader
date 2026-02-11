shader_type canvas_item;
render_mode unshaded;

uniform sampler2D dispace_x;
uniform sampler2D dispace_y;
// Acts as the opaicty
uniform sampler2D dispace_z;

uniform float mix_float;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	vec2 col = vec2(COLOR.r-0.5*2.0,COLOR.g-0.5*2.0)*10.0;
	VERTEX += col;
}

void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	c.rgb = mix(c.rgb,vec3(texture(dispace_x,UV).r,texture(dispace_y,UV).g,texture(dispace_z,UV).b),mix_float);
	
	COLOR = vec4(c.rgb,c.b);
	//COLOR = vertex_color;
}

//void fragment() {
	//vec4 new = texture(TEXTURE,vec2(texture(dispace_x,UV).r,texture(dispace_y,UV).g));
	//COLOR = vec4(texture(dispace_x,UV).r,texture(dispace_y,UV).g,texture(dispace_z,UV).b,1.0);
//}
