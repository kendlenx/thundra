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

setupAnalytics();

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

document.querySelectorAll(".feature-card, .cta").forEach((el) => observer.observe(el));
