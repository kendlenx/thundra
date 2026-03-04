# THUNDRA Website

Static marketing site for `thunda.kendlenx.com`.

## Local Preview

From repo root:

```bash
cd website
python3 -m http.server 8080
```

Open `http://localhost:8080`.

## Deploy (example: Vercel)

1. Create a new Vercel project with root directory set to `website`.
2. Deploy.
3. Add custom domain `thunda.kendlenx.com`.
4. In domain DNS, create a CNAME record:
   - Host: `thunda`
   - Target: your Vercel project domain.
5. Wait for SSL issuance and propagation.

## Files

- `index.html`: page content
- `styles.css`: visual system and responsive layout
- `script.js`: simple reveal animations and dynamic year
