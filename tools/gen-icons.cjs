// One-off generator: builds all app/PWA/launcher icons from Downloads/logo-adp.png
const path = require('path');
const fs = require('fs');
const { createCanvas, loadImage } = require('canvas');

const SRC = 'C:/Users/Team_2/Downloads/logo-adp.png';
const ROOT = process.cwd();
const BG = '#FBF9F5'; // app cream background

async function makeIcon(size, outPath, { bg = BG, scale = 0.78 } = {}) {
  const img = await loadImage(SRC);
  const canvas = createCanvas(size, size);
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, size, size);
  // Fit logo inside square, preserving aspect ratio
  const maxW = size * scale;
  const maxH = size * scale;
  const ratio = Math.min(maxW / img.width, maxH / img.height);
  const w = img.width * ratio;
  const h = img.height * ratio;
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(img, (size - w) / 2, (size - h) / 2, w, h);
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, canvas.toBuffer('image/png'));
  console.log('wrote', path.relative(ROOT, outPath), size + 'x' + size);
}

async function main() {
  const web = (f) => path.join(ROOT, 'web', f);
  const android = (dpi, s) => path.join(ROOT, `android/app/src/main/res/mipmap-${dpi}`, 'ic_launcher.png');

  // Web / PWA icons
  await makeIcon(192, web('icons/Icon-192.png'));
  await makeIcon(512, web('icons/Icon-512.png'));
  await makeIcon(1024, web('icons/Icon-1024.png'));
  await makeIcon(192, web('icons/Icon-maskable-192.png'), { scale: 0.6 });
  await makeIcon(512, web('icons/Icon-maskable-512.png'), { scale: 0.6 });
  await makeIcon(192, web('icons/logo-192.png'));
  await makeIcon(512, web('icons/logo-512.png'));
  await makeIcon(192, web('icons/masked-icon-192.png'), { scale: 0.6 });
  await makeIcon(512, web('icons/masked-icon-512.png'), { scale: 0.6 });
  await makeIcon(180, web('icons/apple-icon-180.png'));
  await makeIcon(512, web('icons/apple-icon.png'));
  await makeIcon(32, web('favicon.png'), { scale: 0.9 });

  // Android launcher icons
  await makeIcon(48, android('mdpi'));
  await makeIcon(72, android('hdpi'));
  await makeIcon(96, android('xhdpi'));
  await makeIcon(144, android('xxhdpi'));
  await makeIcon(192, android('xxxhdpi'));

  // Flutter asset used inside the app (original file, untouched)
  const assetDir = path.join(ROOT, 'assets', 'brand');
  fs.mkdirSync(assetDir, { recursive: true });
  fs.copyFileSync(SRC, path.join(assetDir, 'logo_adp.png'));
  console.log('wrote assets/brand/logo_adp.png (original)');
}

main().catch((e) => { console.error(e); process.exit(1); });