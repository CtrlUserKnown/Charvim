/* === THEME === */
const DEFAULT_THEME = 'knew-pines';
const STORAGE_KEY   = 'charvim-theme';

function getTheme() {
  return localStorage.getItem(STORAGE_KEY) || DEFAULT_THEME;
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem(STORAGE_KEY, theme);

  document.querySelectorAll('.theme-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.theme === theme);
  });

  document.querySelectorAll('.theme-preview').forEach(prev => {
    prev.classList.toggle('active-preview', prev.dataset.theme === theme);
  });
}

/* === CURSOR GRADIENT === */
function initCursorGradient() {
  let tx = 50, ty = 50;
  let cx = 50, cy = 50;

  document.addEventListener('mousemove', e => {
    tx = (e.clientX / window.innerWidth)  * 100;
    ty = (e.clientY / window.innerHeight) * 100;
  });

  (function tick() {
    cx += (tx - cx) * 0.055;
    cy += (ty - cy) * 0.055;
    document.documentElement.style.setProperty('--gx', cx.toFixed(2) + '%');
    document.documentElement.style.setProperty('--gy', cy.toFixed(2) + '%');
    requestAnimationFrame(tick);
  })();
}

/* === COPY BUTTONS === */
function initCopyBtns() {
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const text = btn.closest('.code-block').querySelector('code').textContent;
      navigator.clipboard.writeText(text).then(() => {
        const orig = btn.textContent;
        btn.textContent = '✓';
        btn.style.color = 'var(--foam)';
        setTimeout(() => { btn.textContent = orig; btn.style.color = ''; }, 2000);
      });
    });
  });
}

/* === NAVIGATION === */
function initNav() {
  const page = window.location.pathname.split('/').pop() || 'index.html';

  document.querySelectorAll('.nav-links a').forEach(a => {
    const href = a.getAttribute('href') || '';
    const match = href === page
      || (page === '' && href === 'index.html')
      || (page === 'index.html' && href === 'index.html');
    a.classList.toggle('active', match);
  });

  const burger = document.querySelector('.hamburger');
  const links  = document.querySelector('.nav-links');
  if (burger && links) {
    burger.addEventListener('click', () => links.classList.toggle('open'));
    document.addEventListener('click', e => {
      if (!burger.contains(e.target) && !links.contains(e.target)) {
        links.classList.remove('open');
      }
    });
  }
}

/* === DOCS SIDEBAR SCROLL HIGHLIGHT === */
function initDocsSidebar() {
  const headings = document.querySelectorAll('.docs-content h2[id], .docs-content h3[id]');
  const sideLinks = document.querySelectorAll('.sidebar-links a[href^="#"]');
  if (!headings.length) return;

  const obs = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        sideLinks.forEach(l => {
          l.classList.toggle('active', l.getAttribute('href') === '#' + e.target.id);
        });
      }
    });
  }, { rootMargin: '-64px 0px -55% 0px', threshold: 0 });

  headings.forEach(h => obs.observe(h));
}

/* === THEME PREVIEW CLICK === */
function initThemePreviews() {
  document.querySelectorAll('.theme-preview[data-theme]').forEach(el => {
    el.addEventListener('click', () => applyTheme(el.dataset.theme));
  });
}

/* === BOOT === */
document.addEventListener('DOMContentLoaded', () => {
  applyTheme(getTheme());

  document.querySelectorAll('.theme-btn[data-theme]').forEach(btn => {
    btn.addEventListener('click', () => applyTheme(btn.dataset.theme));
  });

  initCursorGradient();
  initCopyBtns();
  initNav();
  initDocsSidebar();
  initThemePreviews();
});
