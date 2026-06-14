precision highp float;
varying vec2 v_texcoord;// Coordinate from 0.0 to 1.0
uniform sampler2D tex;// Original widget texture
uniform float alpha;// Widget opacity
uniform float time;// Elapsed time in seconds

void main() {
  vec2 uv = v_texcoord;

  // Wave distortion on X-axis based on Y-coordinate and time
  uv.x += sin(uv.y * 10.0 + time * 4.0) * 0.015;
  // Wave distortion on Y-axis based on X-coordinate and time
  uv.y += cos(uv.x * 10.0 + time * 4.0) * 0.015;

  vec4 color = texture2D(tex, uv);
  gl_FragColor = color * alpha;
}
