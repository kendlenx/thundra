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

## Netlify Notes

- Publish directory: `website`
- Build command: _(leave empty)_
- Custom domain: `thunda.kendlenx.com`
- `netlify.toml` includes SPA redirect and cache headers.

## Analytics

`website/index.html` exposes:

```js
window.THUNDRA_ANALYTICS = {
  plausibleDomain: "thunda.kendlenx.com",
  gaMeasurementId: "",
};
```

- Plausible is active by default when `plausibleDomain` is present.
- To enable GA4, set `gaMeasurementId` to your `G-XXXXXXXXXX` value.
- Funnel events now include:
  - `Landing Viewed`
  - `Funnel Step Viewed`
  - `Download CTA Viewed`
  - `Download Click`
  - `Funnel Converted`
  - `FAQ Opened`
  - `Trust Link Click`

## SEO Content

- Feature pages:
  - `features/live-strike-map.html`
  - `features/calm-local-alerts.html`
  - `features/heatmap-and-trends.html`
- Blog:
  - `blog/index.html`
  - `blog/on-device-alerts-without-noise.html`
  - `blog/lightning-safety-checklist.html`
- Trust pages:
  - `privacy-policy.html`
  - `security-and-retention.html`
- Growth reference:
  - `growth-dashboard.html`
- RSS feed:
  - `blog/rss.xml`
- Deep-link fallback:
  - `invite/index.html`

## SEO Notes

- Home and content pages now include stronger metadata:
  - canonical + hreflang
  - Open Graph + Twitter cards
  - structured data (WebPage, BreadcrumbList, ItemList/Blog/Article)
- `sitemap.xml` includes `lastmod` values and content page coverage.
- Invite fallback page is intentionally `noindex,nofollow` to avoid indexing utility links.

## Files

- `index.html`: page content
- `styles.css`: visual system and responsive layout
- `content.css`: style system for feature/blog/policy pages
- `script.js`: simple reveal animations and dynamic year
