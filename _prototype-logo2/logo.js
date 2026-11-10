// PROTOTYPE — throwaway (branch prototype/logo-v2). The new logo redrawn as SVG from the owner's model (logonovo.jpeg):
// outline toque + handlebar mustache + cannabis leaf as the beard, "HOW TO" over "EDIBLES".
// Colour roles are classes so every context remaps them: .k ink, .o orange, .g leaf green, .p hat inside.
// Symbol box: 0 0 100 164 (model px × 0.2857, the model's symbol is 350 × 570 px).

const SW = 5.8; // hat outline, as in the model (≈20 px at 2400 px wide)
// toque = union of 3 puffs and the band; drawn twice (fat stroke, then fill on top) so only the outer outline shows
const HAT_SHAPES = `<circle cx="18" cy="39" r="14.5"/><circle cx="50" cy="26" r="22"/><circle cx="82" cy="40" r="14.5"/><rect x="28" y="37" width="44" height="52"/>`;
const hat = (sw = SW) => `<g fill="var(--lo)" stroke="var(--lo)" stroke-width="${sw * 2}" stroke-linejoin="round">${HAT_SHAPES}</g><g fill="var(--lp)">${HAT_SHAPES}</g>`;

// handlebar mustache: left half (centre bottom → lobe → curled tip → back over the top to the centre notch), mirrored
const MUS_L = [[50, 99], [44, 103, 36, 105, 28, 103], [20, 101, 13, 97, 9.5, 91.5], [6.5, 86.5, 7.5, 81, 12, 80.5], [15.5, 80, 17.5, 83.5, 15, 86], [19.5, 87, 23, 85, 27, 82], [34, 77, 44, 78.5, 50, 85]];
function mustache() {
  const [m, ...cs] = MUS_L, f = (a) => a.map((v, i) => (i % 2 ? v : 100 - v));
  const back = [...cs].reverse().map((c, i, arr) => { const prev = i + 1 < arr.length ? arr[i + 1].slice(4) : m; return f([c[2], c[3], c[0], c[1], ...prev]); });
  return `<path fill="var(--lo)" d="M${m}${cs.map((c) => "C" + c.join(" ")).join("")}${back.map((c) => "C" + c.join(" ")).join("")}Z"/>`;
}

// leaf: 7 lens-shaped leaflets from (50,113.5), angles measured from straight down (positive = to the left)
const LEAFLETS = [[0, 50, 8.4], [50, 43, 7.6], [-50, 43, 7.6], [96, 26, 5.2], [-96, 26, 5.2], [180, 10, 2.6]];
const leaf = () => LEAFLETS.map(([a, L, W]) => `<path fill="var(--lg)" transform="translate(50 113.5) rotate(${a})" d="M0 0C${W} ${L * 0.24} ${W} ${L * 0.58} 0 ${L}C${-W} ${L * 0.58} ${-W} ${L * 0.24} 0 0Z"/>`).join("");

const symbol = (sw) => `${hat(sw)}${mustache()}${leaf()}`;

// lockup: symbol on the left, two justified lines on the right. Text is laid out after the font loads (fit()).
const FONTS = { A: "'Archivo Black'", B: "Unbounded" };
function lockup(v, id = "") {
  return `<svg class="lg lg-${v}" ${id ? `id="${id}"` : ""} viewBox="0 0 432 164" role="img" aria-label="HowToEdibles">${symbol()}
    <text fill="var(--lk)" x="133" y="76" style="font-family:${FONTS[v]};font-weight:${v === "B" ? 800 : 400}">HOW TO</text>
    <text fill="var(--lo)" x="133" y="140" style="font-family:${FONTS[v]};font-weight:${v === "B" ? 800 : 400}">EDIBLES</text></svg>`;
}
// fit both lines to the model's text box: x 133→431, HOW TO cap top 24, EDIBLES baseline 140
function fit(svg) {
  const [a, b] = svg.querySelectorAll("text");
  const W = 298;
  for (const t of [a, b]) { t.setAttribute("font-size", 100); t.removeAttribute("textLength"); }
  const capH = (t) => { const bb = t.getBBox(); return bb.height; };
  // EDIBLES sets the size: as wide as the box
  const s = 100 * W / b.getComputedTextLength();
  b.setAttribute("font-size", s.toFixed(2));
  a.setAttribute("font-size", s.toFixed(2));
  a.setAttribute("textLength", W); a.setAttribute("lengthAdjust", "spacingAndGlyphs"); // HOW TO is shorter: widen its letters like the model, not the gaps
  b.setAttribute("textLength", W); b.setAttribute("lengthAdjust", "spacing");
  // two lines centred on the hat + mustache (y 2 → 104 in the model ≈ text box 24 → 140)
  const cap = s * (svg.classList.contains("lg-B") ? 0.7 : 0.72), gap = cap * 0.24, top = 82 - (2 * cap + gap) / 2;
  a.setAttribute("y", (top + cap).toFixed(2));
  b.setAttribute("y", (top + 2 * cap + gap).toFixed(2));
}
