const yearEl = document.getElementById("year");
if (yearEl) yearEl.textContent = new Date().getFullYear().toString();

function setupAnalytics() {
  const config = window.THUNDRA_ANALYTICS || {};

  if (config.plausibleDomain) {
    const plausible = document.createElement("script");
    plausible.defer = true;
    plausible.dataset.domain = config.plausibleDomain;
    plausible.src = "https://plausible.io/js/script.js";
    document.head.appendChild(plausible);
  }

  if (config.gaMeasurementId) {
    const gtagLib = document.createElement("script");
    gtagLib.async = true;
    gtagLib.src = `https://www.googletagmanager.com/gtag/js?id=${config.gaMeasurementId}`;
    document.head.appendChild(gtagLib);

    window.dataLayer = window.dataLayer || [];
    window.gtag = function gtag() {
      window.dataLayer.push(arguments);
    };
    window.gtag("js", new Date());
    window.gtag("config", config.gaMeasurementId, { anonymize_ip: true });
  }
}

function getAbVariant() {
  const storageKey = "thundra_hero_ab_v1";
  try {
    const existing = localStorage.getItem(storageKey);
    if (existing === "a" || existing === "b") return existing;
    const next = Math.random() < 0.5 ? "a" : "b";
    localStorage.setItem(storageKey, next);
    return next;
  } catch (_) {
    return "a";
  }
}

function applyHeroAbVariant(variant) {
  const title = document.getElementById("hero-title");
  const heroPrimaryCta = document.querySelector('[data-placement="hero_primary"]');
  const key = variant === "b" ? "variantB" : "variantA";

  if (title?.dataset[key]) title.textContent = title.dataset[key];
  if (heroPrimaryCta?.dataset[key]) heroPrimaryCta.textContent = heroPrimaryCta.dataset[key];
}

function detectStorefront(defaultCountry) {
  const fallback = (defaultCountry || "tr").toLowerCase();
  const locale = (navigator.languages && navigator.languages[0]) || navigator.language || "";
  const regionFromLocale = locale.includes("-") ? locale.split("-")[1] : "";
  const region = (regionFromLocale || "").toLowerCase();
  return /^[a-z]{2}$/.test(region) ? region : fallback;
}

function buildStoreUrl({
  country,
  slug,
  appId,
  pt,
  mt,
  ct,
}) {
  const url = new URL(`https://apps.apple.com/${country}/app/${slug}/id${appId}`);
  if (pt) url.searchParams.set("pt", pt);
  if (ct) url.searchParams.set("ct", ct);
  if (mt) url.searchParams.set("mt", mt);
  return url.toString();
}

function setupDownloadTracking(variant) {
  const body = document.body;
  if (!body) return;

  const appId = body.dataset.appId || "6756683794";
  const appSlug = body.dataset.appSlug || "thundra";
  const defaultCountry = body.dataset.appstoreDefaultCountry || "tr";
  const pt = body.dataset.utmPt || "thundra_web";
  const mt = body.dataset.utmMt || "8";
  const country = detectStorefront(defaultCountry);
  const links = document.querySelectorAll(".js-download-cta");

  links.forEach((link) => {
    const placement = link.getAttribute("data-placement") || "unknown";
    const ct = `landing_${placement}_${variant}`;
    link.setAttribute(
      "href",
      buildStoreUrl({ country, slug: appSlug, appId, pt, mt, ct })
    );

    link.addEventListener("click", () => {
      const payload = {
        placement,
        destination: "app_store",
        variant,
      };

      if (typeof window.plausible === "function") {
        window.plausible("Download Click", { props: payload });
      }

      if (typeof window.gtag === "function") {
        window.gtag("event", "download_click", payload);
      }
    });
  });
}

function setupRevealAnimations() {
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.animate(
          [
            { transform: "translateY(12px)", opacity: 0 },
            { transform: "translateY(0)", opacity: 1 },
          ],
          { duration: 550, easing: "cubic-bezier(.2,.8,.2,1)", fill: "forwards" }
        );
        observer.unobserve(entry.target);
      });
    },
    { threshold: 0.15 }
  );

  document
    .querySelectorAll(".feature-card, .trust-card, .how-step, .faq-item, .cta")
    .forEach((el) => observer.observe(el));
}

setupAnalytics();
const variant = getAbVariant();
applyHeroAbVariant(variant);
setupDownloadTracking(variant);
setupRevealAnimations();
