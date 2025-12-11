generate-webp.sh — Usage

This script generates resized WebP image variants for responsive `srcset` usage.

Prerequisites (macOS):
- Homebrew (recommended)
- cwebp: `brew install webp`
- Optional: ImageMagick if you want better resizing controls: `brew install imagemagick`
  - The script uses `sips` (built-in on macOS) by default and falls back to `magick`.

Run (process all images in `assets/images`):

```bash
chmod +x scripts/generate-webp.sh
./scripts/generate-webp.sh
```

Run for a single file:

```bash
./scripts/generate-webp.sh assets/images/hero.jpg
```

Output files
- For `hero.jpg` the script will produce `hero-1600.webp`, `hero-800.webp`, `hero-480.webp` next to the source file.

Recommended follow-up
- Review generated files and commit them to the repository (or upload to your CDN).
- Adjust `SIZES` or `QUALITY` in the script if needed.
- If you prefer Node.js-based tooling with `sharp`, I can provide that instead.
