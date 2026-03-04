const yearEl = document.getElementById("year");
if (yearEl) yearEl.textContent = new Date().getFullYear().toString();

function trackEvent(name, props = {}) {
  if (typeof window.plausible === "function") {
    window.plausible(name, { props });
  }

  if (typeof window.gtag === "function") {
    window.gtag("event", name.toLowerCase().replace(/\s+/g, "_"), props);
  }

  if (window.THUNDRA_ANALYTICS?.debug) {
    // eslint-disable-next-line no-console
    console.log("[THUNDRA analytics]", name, props);
  }
}

function trackOnceInSession(key, name, props = {}) {
  try {
    const sessionKey = `thundra_evt_${key}`;
    if (sessionStorage.getItem(sessionKey)) return;
    sessionStorage.setItem(sessionKey, "1");
  } catch (_) {
    // no-op
  }
  trackEvent(name, props);
}

function getAttributionProps() {
  const url = new URL(window.location.href);
  const referrerHost = (() => {
    try {
      return document.referrer ? new URL(document.referrer).host : "direct";
    } catch (_) {
      return "direct";
    }
  })();

  return {
    utm_source: url.searchParams.get("utm_source") || "(none)",
    utm_medium: url.searchParams.get("utm_medium") || "(none)",
    utm_campaign: url.searchParams.get("utm_campaign") || "(none)",
    referrer_host: referrerHost,
  };
}

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
        country,
      };

      trackEvent("Download Click", payload);
      trackEvent("Funnel Converted", payload);
    });
  });
}

function setupFunnelTracking(variant) {
  const baseProps = {
    variant,
    ...getAttributionProps(),
  };

  trackOnceInSession("landing_view", "Landing Viewed", baseProps);

  const sectionSteps = [
    { selector: "#features", step: "features" },
    { selector: "#why-thundra", step: "trust" },
    { selector: "#how", step: "how_it_works" },
    { selector: "#screens", step: "screens" },
    { selector: "#cta", step: "cta" },
    { selector: "#faq", step: "faq" },
  ];

  const sectionObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const step = entry.target.getAttribute("data-step-name");
        if (!step) return;
        trackOnceInSession(`step_${step}`, "Funnel Step Viewed", {
          ...baseProps,
          step,
        });
        sectionObserver.unobserve(entry.target);
      });
    },
    { threshold: 0.28 }
  );

  sectionSteps.forEach(({ selector, step }) => {
    const el = document.querySelector(selector);
    if (!el) return;
    el.setAttribute("data-step-name", step);
    sectionObserver.observe(el);
  });

  const ctaObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const placement = entry.target.getAttribute("data-placement");
        if (!placement) return;
        trackOnceInSession(`cta_view_${placement}`, "Download CTA Viewed", {
          ...baseProps,
          placement,
        });
      });
    },
    { threshold: 0.75 }
  );

  document.querySelectorAll(".js-download-cta").forEach((cta) => {
    ctaObserver.observe(cta);
  });

  document.querySelectorAll(".faq-item").forEach((item) => {
    item.addEventListener("toggle", () => {
      if (!(item instanceof HTMLDetailsElement) || !item.open) return;
      const faqId = item.dataset.faqId || "unknown";
      const question = item.querySelector("summary")?.textContent?.trim() || faqId;
      trackEvent("FAQ Opened", {
        ...baseProps,
        faq_id: faqId,
        question,
      });
    });
  });

  document.querySelectorAll(".js-trust-link").forEach((link) => {
    link.addEventListener("click", () => {
      const linkId = link.getAttribute("data-trust-link") || "unknown";
      trackEvent("Trust Link Click", {
        ...baseProps,
        link_id: linkId,
      });
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
    .querySelectorAll(
      ".feature-card, .learn-card, .trust-card, .trust-fact, .how-step, .faq-item, .cta"
    )
    .forEach((el) => observer.observe(el));
}

setupAnalytics();
const variant = getAbVariant();
applyHeroAbVariant(variant);
setupDownloadTracking(variant);
setupFunnelTracking(variant);
setupRevealAnimations();
