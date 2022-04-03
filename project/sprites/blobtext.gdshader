// this is a 2D CanvasItem shader
// adapted from https://www.instructables.com/Code-a-Lava-Lamp-With-the-Godot-Game-Engine/
shader_type canvas_item;

uniform float blob_threshold = 1.15;

uniform vec4 background_col: hint_color = vec4(1.0, 0, 1.0, 0);
uniform vec4 blob_col: hint_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform sampler2D mask_texture;

float oscillate(float x, float offset, float speed) {
	return pow(sin(speed * x + offset), 2)/2.0+0.5;
}

void fragment() {
	// color each fragment the Sprite covers black
	//vec4 background_color_here = mix(background_edge, background_center, abs(0.5 - UV.x));
	COLOR = background_col;
	// declare the blob_centers as
	// a changing array of vec3s
	// with length 2 (2 elements)
	vec3 blob_centers[8];
	// define the blob centers
	// we start counting at 0
	blob_centers[0] = vec3(-0.3 + oscillate(TIME, 0.1, 0.1), 0.5, 4.0);
	blob_centers[1] = vec3(-0.3 + oscillate(TIME, 0.2, 0.2),  0.4, 2.0);
	blob_centers[2] = vec3(-0.3 + oscillate(TIME, 0.2, 0.05),  0.35, 6.0);
	blob_centers[3] = vec3(-0.3 + oscillate(TIME, 0.1, 0.3),  0.55, 4.0);
	blob_centers[4] = vec3(-0.3 + oscillate(TIME, 0.1, 0.2),  0.6, 8.0);
	blob_centers[5] = vec3(-0.3 + oscillate(TIME, 0.05, 0.15),  0.65, 7.0);

	blob_centers[7] = vec3(0.5, 0.6, 3.0);
	blob_centers[7] = vec3(0.8, 0.5, 2.0);

	// start counting influence at 0
	float influence = -0.2;
	// for each of the blobs, we add some influence based on how close
	// this point is to each blob
	for (int i = 0; i < blob_centers.length(); i++) {
		// TODO: explain each of these variables
		float distance_to_blob_center = distance(blob_centers[i].xy / TEXTURE_PIXEL_SIZE, UV / TEXTURE_PIXEL_SIZE);
		influence += blob_centers[i].z * (1.0 / distance_to_blob_center);
	}
	// if influence is larger than a certain threshold, set the color at this
	// point to the gradient
	// COLOR = mix(background_color_here, mix(blob_top, blob_bottom, UV.y), pow(influence, 6));
	vec4 mask_colour = texture(mask_texture, UV);
    // mask_colour.a *= texture(mask_texture, UV).a;
	if (influence > blob_threshold) {
		// COLOR = mix(blob_top, blob_bottom, UV.y);
		COLOR =  mask_colour;
	}
	
}