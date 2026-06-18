/* Service worker — The Church of Pentecost, Anyaa District */
const CACHE = 'cop-anyaa-v2';
const ASSETS = [
  './', './index.html', './config.js', './manifest.webmanifest',
  './icon-192.png', './icon-512.png', './icon-maskable-512.png',
  './apple-touch-icon.png', './logo.png'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});
self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // Never intercept Supabase or the AI API — always go straight to network
  if (url.hostname.endsWith('.supabase.co') || url.hostname === 'api.anthropic.com') return;

  e.respondWith(
    caches.match(req).then((cached) => {
      const network = fetch(req).then((res) => {
        const sameOrigin = url.origin === location.origin;
        const isFont = url.hostname.includes('gstatic') || url.hostname.includes('googleapis');
        if (res && res.status === 200 && (sameOrigin || isFont)) {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(req, copy)).catch(() => {});
        }
        return res;
      }).catch(() => cached);
      return cached || network;
    })
  );
});
