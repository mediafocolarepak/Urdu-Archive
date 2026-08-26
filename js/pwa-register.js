// Registers the service worker if the browser supports it. Silently does nothing on
// browsers without support (older Safari/Firefox configs) - PWA install is a bonus, never
// a requirement to use the app.
export function registerServiceWorker() {
  if (!('serviceWorker' in navigator)) return;
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').catch(err => console.warn('Service worker registration failed:', err));
  });
}
