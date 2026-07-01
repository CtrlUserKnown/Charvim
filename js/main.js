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
    function closeNav() {
      links.classList.remove('open');
      burger.classList.remove('open');
      burger.setAttribute('aria-expanded', 'false');
    }

    burger.addEventListener('click', e => {
      e.stopPropagation();
      const isOpen = links.classList.toggle('open');
      burger.classList.toggle('open', isOpen);
      burger.setAttribute('aria-expanded', String(isOpen));
    });

    links.querySelectorAll('a').forEach(a => a.addEventListener('click', closeNav));

    document.addEventListener('click', e => {
      if (!burger.contains(e.target) && !links.contains(e.target)) closeNav();
    });

    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') closeNav();
    });
  }
}

/* === THEME FAB === */
function initThemeFab() {
  const fab   = document.querySelector('.theme-fab');
  const popup = document.querySelector('.theme-fab-popup');
  if (!fab || !popup) return;

  function closeFab() {
    popup.classList.remove('open');
    fab.classList.remove('open');
    fab.setAttribute('aria-expanded', 'false');
  }

  fab.addEventListener('click', e => {
    e.stopPropagation();
    const isOpen = popup.classList.toggle('open');
    fab.classList.toggle('open', isOpen);
    fab.setAttribute('aria-expanded', String(isOpen));
  });

  popup.addEventListener('click', e => {
    if (e.target.closest('.theme-btn[data-theme]')) closeFab();
  });

  document.addEventListener('click', e => {
    if (!fab.contains(e.target) && !popup.contains(e.target)) closeFab();
  });

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeFab();
  });
}

/* === NEOVIM TYPER ANIMATION === */
function initNvimTyper() {
  const h1 = document.querySelector('.hero-name');
  if (!h1 || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  const TEXT    = 'CharVim';
  const CHAR_MS = 72;
  const wait    = ms => new Promise(r => setTimeout(r, ms));

  // Bar lives in the DOM permanently; starts collapsed
  const bar = document.createElement('div');
  bar.className = 'nvim-bar nvim-bar--done';
  bar.setAttribute('aria-hidden', 'true');
  bar.innerHTML = '<span class="nvim-bar-mode"> </span>';
  h1.insertAdjacentElement('afterend', bar);
  const modeEl = bar.querySelector('.nvim-bar-mode');

  function setNormal(caret, ch) {
    caret.className    = 'nvim-caret nvim-caret--normal';
    caret.textContent  = ch;
    modeEl.textContent = 'NORMAL';
    bar.className      = 'nvim-bar';
  }

  function setInsert(caret) {
    caret.className    = 'nvim-caret nvim-caret--insert';
    caret.textContent  = '';
    modeEl.textContent = '-- INSERT --';
    bar.className      = 'nvim-bar nvim-bar--insert';
  }

  async function animate() {
    // Rebuild animation spans fresh each run
    h1.setAttribute('aria-label', TEXT);
    h1.innerHTML = '<span class="nvim-pre"></span>'
                 + '<span class="nvim-caret"></span>'
                 + '<span class="nvim-post"></span>';
    const pre   = h1.querySelector('.nvim-pre');
    const caret = h1.querySelector('.nvim-caret');
    const post  = h1.querySelector('.nvim-post');

    // 1. NORMAL mode — bar slides in, empty block cursor
    setNormal(caret, ' ');
    await wait(280);

    // 2. Enter INSERT
    setInsert(caret);
    pre.textContent = '';
    await wait(110);

    // 3. Type each character
    let typed = '';
    for (const ch of TEXT) {
      typed += ch;
      pre.textContent = typed;
      await wait(CHAR_MS);
    }

    // 4. Hold at end
    await wait(260);

    // 5. ESC back to NORMAL, cursor on last char
    pre.textContent  = TEXT.slice(0, -1);
    post.textContent = '';
    setNormal(caret, TEXT.at(-1));
    await wait(180);

    // 6. Cursor travels left to position 0
    for (let i = TEXT.length - 2; i >= 0; i--) {
      pre.textContent   = TEXT.slice(0, i);
      caret.textContent = TEXT[i];
      post.textContent  = TEXT.slice(i + 1);
      await wait(38);
    }

    // 7. Hold on 'C'
    await wait(340);

    // 8. Bar collapses
    bar.classList.add('nvim-bar--done');
    await wait(380);

    // 9. Restore plain h1
    h1.textContent = TEXT;
    h1.removeAttribute('aria-label');
  }

  async function loop() {
    while (true) {
      await animate();
      // Replay every 30-40 s (randomised so it never feels mechanical)
      await wait(30000 + Math.random() * 10000);
    }
  }

  loop();
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
  initThemeFab();
  initNvimTyper();
});
