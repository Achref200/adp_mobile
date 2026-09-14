// Vercel Serverless Function for ADP Backend
// This adapts the Fastify app to work in Vercel's serverless environment

// Import from compiled dist for Vercel deployment
import { buildApp } from '../dist/src/app.js';

let appPromise: Promise<ReturnType<typeof buildApp>> | null = null;

async function getApp() {
  if (!appPromise) {
    appPromise = buildApp().then((app) => app.ready().then(() => app));
  }
  return appPromise;
}

// Simple HTTP request/response adapters for Vercel
class VercelRequest {
  constructor(
    public method: string,
    public url: string,
    public headers: Record<string, string>,
    public body: any
  ) {}
}

class VercelResponse {
  statusCode = 200;
  headers: Record<string, string> = {};
  body = '';

  setHeader(key: string, value: string) {
    this.headers[key] = value;
  }

  status(code: number) {
    this.statusCode = code;
    return this;
  }

  json(data: any) {
    this.setHeader('Content-Type', 'application/json');
    this.body = JSON.stringify(data);
    return this;
  }

  send(data: string | Buffer) {
    this.body = data.toString();
    return this;
  }
}

export default async function handler(req: any, res: any) {
  try {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
      res.statusCode = 204;
      res.end();
      return;
    }

    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Build request body if present
    let body: any = undefined;
    if (req.body) {
      try {
        body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
      } catch {
        body = req.body;
      }
    }

    // Create Fastify-compatible request
    const fastifyReq = {
      method: req.method,
      url: req.url || '/',
      headers: req.headers || {},
      body: body,
      params: {},
      query: {},
    };

    // Parse query string
    if (fastifyReq.url.includes('?')) {
      const [path, queryStr] = fastifyReq.url.split('?');
      fastifyReq.url = path;
      fastifyReq.query = Object.fromEntries(new URLSearchParams(queryStr));
    }

    // Create response container
    let responseBody: string | null = null;
    let responseStatusCode = 200;
    const responseHeaders: Record<string, string> = {};

    const fastifyRes = {
      status(code: number) {
        responseStatusCode = code;
        return this;
      },
      send(data: any) {
        responseBody = typeof data === 'string' ? data : JSON.stringify(data);
        return this;
      },
      header(key: string, value: string) {
        responseHeaders[key] = value;
      },
      getHeader(key: string) {
        return responseHeaders[key];
      },
    };

    // Get the Fastify app and handle the request
    const app = await getApp();
    
    // Use Fastify's internal handler
    await app.handle(fastifyReq as any, fastifyRes as any);

    // Send response back to Vercel
    res.statusCode = responseStatusCode;
    for (const [key, value] of Object.entries(responseHeaders)) {
      res.setHeader(key, value);
    }
    
    if (responseBody !== null) {
      res.end(responseBody);
    } else {
      res.status(204).end();
    }
  } catch (error) {
    console.error('Vercel API Handler Error:', error);
    res.statusCode = 500;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({
      error: {
        code: 'internal_error',
        message: error instanceof Error ? error.message : 'Internal server error'
      }
    }));
  }
}
