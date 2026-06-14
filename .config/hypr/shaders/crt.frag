precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float alpha;
uniform float time;
uniform vec2 resolution;

// Pseudo-random noise helper
float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

void main() {
  vec2 uv = v_texcoord;

  // 1 - Generate horizontal glitch offsets (tearing lines)
  float timeSnap = floor(time * 8.0); // 8 glitch steps per second
  float lineNoise = hash(vec2(floor(uv.y * 12.0), timeSnap));

  float glitchShift = 0.0;
  if (lineNoise > 0.82) { // 18% chance of glitch shift per band
    glitchShift = (hash(vec2(timeSnap, uv.y)) - 0.5) * 0.04;
  }

  // Add a periodic vertical rolling warp
  float roll = sin(uv.y * 3.0 - time * 2.0);
  if (hash(vec2(timeSnap)) > 0.95) { // Occasional extreme roll
    glitchShift += roll * 0.02;
  }

  // Apply the horizontal offset
  uv.x += glitchShift;

  // 2 - Chromatic Aberration (RGB channel splitting)
  float splitAmount = 0.007 + sin(time * 5.0) * 0.004;

  vec2 uvR = uv + vec2(splitAmount, 0.0);
  vec2 uvG = uv;
  vec2 uvB = uv - vec2(splitAmount, 0.0);

  // Keep coordinates within bounds to avoid wrapping edge issues
  uvR = clamp(uvR, 0.0, 1.0);
  uvB = clamp(uvB, 0.0, 1.0);

  float r = texture2D(tex, uvR).r;
  float g = texture2D(tex, uvG).g;
  float b = texture2D(tex, uvB).b;
  float a = (texture2D(tex, uvR).a + texture2D(tex, uvG).a + texture2D(tex, uvB).a) / 3.0;

  vec4 color = vec4(r, g, b, a);

  // 3 - CRT Scanline overlay                                                                                         ▀
  float scanline = sin(uv.y * resolution.y * 0.8 + time * 12.0) * 0.08;
  color.rgb -= vec3(scanline);

  // 4 - Low-fi TV Static Grain
  float grain = (hash(uv * time) - 0.5) * 0.06;
  color.rgb += vec3(grain);

  gl_FragColor = color * alpha;
}
