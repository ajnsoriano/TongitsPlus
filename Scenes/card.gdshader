shader_type canvas_item;

uniform float outline_size = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 out_col = tex;

    // compute pixel offset in UV space
    vec2 px = TEXTURE_PIXEL_SIZE * max(outline_size, 1.0);

    // only attempt outline where the current pixel is transparent
    if (tex.a <= 0.0) {
        float alpha_sum = 0.0;

        // 4 cardinal directions
        alpha_sum += texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
        alpha_sum += texture(TEXTURE, UV - vec2(px.x, 0.0)).a;
        alpha_sum += texture(TEXTURE, UV + vec2(0.0, px.y)).a;
        alpha_sum += texture(TEXTURE, UV - vec2(0.0, px.y)).a;

        // 4 diagonals
        alpha_sum += texture(TEXTURE, UV + vec2(px.x, px.y)).a;
        alpha_sum += texture(TEXTURE, UV + vec2(-px.x, px.y)).a;
        alpha_sum += texture(TEXTURE, UV + vec2(px.x, -px.y)).a;
        alpha_sum += texture(TEXTURE, UV + vec2(-px.x, -px.y)).a;

        if (alpha_sum > 0.0) {
            out_col = outline_color;
        } else {
            out_col = tex;
        }
    } else {
        out_col = tex;
    }

    COLOR = out_col;
}