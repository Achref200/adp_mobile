// Vercel Serverless Function for ADP Backend
// Adapts the Fastify app (built to backend/dist) to Vercel using app.inject().
import { buildApp } from '../backend/dist/src/app.js';

let appPromise = null;

async function getApp() {
  if (!appPromise) {
    appPromise = (async () => {
      const app = buildApp();
      await app.ready();
      return app;
    })();
  }
  return appPromise;
}

export default async function handler(req, res) {
  try {
    const app = await getApp();

    let payload;
    if (req.body != null) {
      payload = typeof req.body === 'string' ? req.body : JSON.stringify(req.body);
    }

    const response = await app.inject({
      method: req.method || 'GET',
      url: req.url || '/',
      headers: req.headers || {},
      payload,
    });

    res.statusCode = response.statusCode;
    for (const [key, value] of Object.entries(response.headers)) {
      if (value != null) {
        res.setHeader(key, Array.isArray(value) ? value.join(', ') : String(value));
      }
    }
    res.end(response.body);
  } catch (error) {
    console.error('Vercel API Handler Error:', error);
    res.statusCode = 500;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({
      error: {
        code: 'internal_error',
        message: error instanceof Error ? error.message : 'Internal server error',
      },
    }));
  }
}