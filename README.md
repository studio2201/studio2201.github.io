# studio2201.github.io

Public website for the [studio2201](https://github.com/studio2201) organization.

**Live:** https://studio2201.github.io

## Contents

| Path | Purpose |
|------|---------|
| `index.html` | Landing page — services, games, ports, install |
| `styles.css` | Site styles (neon night theme matching brand banner) |
| `assets/` | Logo, banner, app icons |
| `packages/install.sh` | Install helper referenced from app READMEs |

## Local preview

```bash
python3 -m http.server 8080 --directory .
# open http://localhost:8080
```

## Deploy

Push to `master`. GitHub Pages serves from the root of this repository.
