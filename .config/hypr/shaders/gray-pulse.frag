precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float alpha;
uniform float time;

void main() {
  vec4 color = texture2D(tex, v_texcoord);

  // Standard luminosity coefficients for converting RGB to grayscale
  float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));

  // Pulse multiplier that oscillates between 0.7 and 1.3
  float pulse = 1.0 + sin(time * 3.0) * 0.3;

  gl_FragColor = vec4(vec3(gray) * pulse, color.a) * alpha;
}
