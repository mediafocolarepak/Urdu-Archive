// Registers the service worker if the browser supports it. Silently does nothing on
// browsers without support (older Safari/Firefox configs) - PWA install is a bonus, never
// a requirement to use the app.
export function registerServiceWorker() {
  if (!('serviceWorker' in navigator)) return;
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').catch(err => console.warn('Service worker registration failed:', err));
  });
}

// ---------- "Install the app" invitation ----------
// The manifest and service worker already make the app installable, but nothing ever told anyone:
// on Android Chrome the install prompt has to be caught and offered by us, and on iPhone there is
// no prompt at all - the user has to know "Share -> Add to Home Screen". Many members are not at
// ease with apps, forget the link, and never find the shortcut, so this puts the invitation
// where they are. Shown only on phones/tablets, only when not already installed, and a
// "Not now" is remembered for two weeks. Self-contained on purpose (no import from core.js): the
// install event fires on page load, long before anyone is signed in.
const INSTALL_SNOOZE_KEY = 'installBannerSnoozedUntil';
const INSTALL_SNOOZE_DAYS = 14;
let deferredInstallPrompt = null;

// beforeinstallprompt fires once, early; it must be caught at module load, not after sign-in.
window.addEventListener('beforeinstallprompt', e => {
  e.preventDefault();
  deferredInstallPrompt = e;
  showInstallBanner();
});
window.addEventListener('appinstalled', () => { deferredInstallPrompt = null; hideInstallBanner(); });

function isStandalone() {
  return window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
}
// iPadOS reports itself as a Mac, hence the touch-points check.
function isIos() {
  return /iphone|ipad|ipod/i.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
}
function isPhoneSized() {
  return window.matchMedia('(max-width: 900px)').matches || window.matchMedia('(pointer: coarse)').matches;
}
function snoozed() {
  try { return Number(localStorage.getItem(INSTALL_SNOOZE_KEY) || 0) > Date.now(); } catch { return false; }
}
function snooze() {
  try { localStorage.setItem(INSTALL_SNOOZE_KEY, String(Date.now() + INSTALL_SNOOZE_DAYS * 86400000)); } catch { /* private mode: it will simply show again */ }
}
function hideInstallBanner() { document.getElementById('install-banner')?.remove(); }

function shouldOfferInstall() {
  return !isStandalone() && isPhoneSized() && !snoozed() && (deferredInstallPrompt || isIos());
}

function showInstallBanner() {
  if (document.getElementById('install-banner') || !document.body || !shouldOfferInstall()) return;
  const banner = document.createElement('div');
  banner.id = 'install-banner';
  banner.className = 'install-banner';
  banner.innerHTML = `
    <div class="install-banner-text">
      <strong>Install the app on your phone</strong>
      <span>Open it from your home screen, like any other app - no link to remember.</span>
    </div>
    <div class="btn-row" style="margin:0;">
      <button class="btn" id="install-banner-go">Install</button>
      <button class="btn secondary" id="install-banner-later">Not now</button>
    </div>`;
  document.body.prepend(banner);
  document.getElementById('install-banner-later').addEventListener('click', () => { snooze(); hideInstallBanner(); });
  document.getElementById('install-banner-go').addEventListener('click', async () => {
    if (deferredInstallPrompt) {
      deferredInstallPrompt.prompt();
      await deferredInstallPrompt.userChoice;
      deferredInstallPrompt = null; // a prompt can only be used once
      hideInstallBanner();
    } else {
      openIosInstallSteps();
    }
  });
}

// Three plain steps with the actual Share icon drawn, for someone who will not read much.
function openIosInstallSteps() {
  document.getElementById('install-steps-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'install-steps-popup';
  backdrop.className = 'overlay-backdrop';
  const shareIcon = `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-5px;" aria-hidden="true"><path d="M12 3v12"/><path d="M8 7l4-4 4 4"/><path d="M5 11v9h14v-9"/></svg>`;
  backdrop.innerHTML = `
    <div class="panel overlay-panel" style="max-width:420px;">
      <h2 style="margin-top:0;">Put the app on your home screen</h2>
      <ol style="padding-left:20px;line-height:1.9;font-size:15px;">
        <li>Tap the <b>Share</b> button ${shareIcon} (a square with an arrow pointing up) at the bottom or top of the screen.</li>
        <li>Scroll down and tap <b>Add to Home Screen</b>.</li>
        <li>Tap <b>Add</b>. The app icon now sits on your home screen.</li>
      </ol>
      <p class="hint">Can't see the Share button? Open this page in <b>Safari</b> first, then follow the same steps.</p>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn" id="install-steps-close">Got it</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('install-steps-close').addEventListener('click', () => backdrop.remove());
}

// Called once from app.js after the page is parsed. Android shows the banner when the browser's
// install event arrives (above); iPhone has no such event, so it is shown straight away.
export function initInstallBanner() {
  if (isIos()) showInstallBanner();
  else if (deferredInstallPrompt) showInstallBanner();
}
