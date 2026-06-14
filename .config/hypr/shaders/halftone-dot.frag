precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float alpha;
uniform vec2 resolution;

void main() {
  vec4 color = texture2D(tex, v_texcoord);

  // 1. Grid scaling - controls dot size density
  float gridSize = 6.0;
  vec2 gridPos = v_texcoord * resolution / gridSize;

  // 2. Find local coordinate within each grid cell (-0.5 to 0.5)
  vec2 localCoord = fract(gridPos) - vec2(0.5);

  // 3. Determine the dot size based on the brightness of the widget texture
  float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
  float maxRadius = 0.2; // Maximum dot radius
  float dotRadius = brightness * maxRadius;

  // 4. Render the dots (anti-aliased circle drawing)                                                                ▀
  float dist = length(localCoord);

  float edge = 0.08;
  float inCircle = smoothstep(dotRadius + edge, dotRadius - edge, dist);

  // Blend dot color with original texture color
  vec3 finalRGB = mix(color.rgb * 0.3, color.rgb, 1.0 - inCircle);

  gl_FragColor = vec4(finalRGB, color.a) * alpha;
}
