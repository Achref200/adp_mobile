/**
 * ADP Hash-based SPA Router
 * Mimics Flutter GoRouter paths exactly
 */

class AdpRouter {
  constructor() {
    this.routes = {};
    this.currentRoute = null;
    this.currentParams = {};
    this.onRouteChanged = null;

    window.addEventListener('hashchange', () => this.handleHashChange());
  }

  register(path, handler) {
    this.routes[path] = handler;
  }

  navigate(path, params = {}) {
    let queryString = '';
    const keys = Object.keys(params);
    if (keys.length > 0) {
      queryString = '?' + keys.map(k => `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`).join('&');
    }
    window.location.hash = path + queryString;
  }

  init(defaultPath = '#splash') {
    if (!window.location.hash) {
      window.location.hash = defaultPath;
    } else {
      this.handleHashChange();
    }
  }

  handleHashChange() {
    let rawHash = window.location.hash.slice(1); // remove '#'
    if (!rawHash) rawHash = 'splash';

    // Parse query params if any
    let [path, queryString] = rawHash.split('?');
    if (!path.startsWith('/')) path = '/' + path;

    const params = {};
    if (queryString) {
      const searchParams = new URLSearchParams(queryString);
      for (const [key, value] of searchParams.entries()) {
        params[key] = value;
      }
    }

    this.currentRoute = path;
    this.currentParams = params;

    // Determine bottom nav visibility
    const shellRoutes = ['/home', '/projects', '/epass', '/profile'];
    const isInShell = shellRoutes.includes(path);

    // Call registered route handler
    const handler = this.routes[path] || this.routes['/home'];
    if (handler) {
      handler(params, isInShell);
    }

    if (this.onRouteChanged) {
      this.onRouteChanged(path, isInShell);
    }
  }
}

window.adpRouter = new AdpRouter();
