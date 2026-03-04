const yearEl = document.getElementById("year");
if (yearEl) yearEl.textContent = new Date().getFullYear().toString();

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
