import fs from 'node:fs';
import path from 'node:path';
import { Pool } from 'pg';
import bcrypt from 'bcryptjs';
import { env } from './env.js';
let activeDb;
// Helper to create SQLite fallback with real schema & seeds
function createSqliteDb() {
    const { DatabaseSync } = process.getBuiltinModule ? process.getBuiltinModule('node:sqlite') : require('node:sqlite');
    const dbDir = path.resolve(process.cwd(), 'database');
    if (!fs.existsSync(dbDir)) {
        fs.mkdirSync(dbDir, { recursive: true });
    }
    const dbPath = path.join(dbDir, 'adp.sqlite');
    const sqlite = new DatabaseSync(dbPath);
    // Initialize SQLite tables if not present
    sqlite.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      country TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      directory_visible INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      deleted_at TEXT
    );

    CREATE TABLE IF NOT EXISTS refresh_tokens (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      token_hash TEXT NOT NULL UNIQUE,
      expires_at TEXT NOT NULL,
      revoked_at TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS memberships (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      plan TEXT NOT NULL,
      amount_cents INTEGER NOT NULL,
      djerba_connection TEXT,
      motivation TEXT,
      status TEXT NOT NULL DEFAULT 'draft',
      submitted_at TEXT,
      paid_at TEXT,
      expires_at TEXT,
      rejection_reason TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS projects (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      summary TEXT NOT NULL,
      body TEXT,
      location TEXT NOT NULL DEFAULT 'Djerba',
      progress REAL NOT NULL DEFAULT 0,
      target_cents INTEGER,
      raised_cents INTEGER NOT NULL DEFAULT 0,
      featured INTEGER NOT NULL DEFAULT 0,
      published INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS news (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      excerpt TEXT NOT NULL,
      body TEXT,
      category TEXT,
      cover_image_url TEXT,
      published INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS events (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      summary TEXT,
      location TEXT,
      starts_at TEXT,
      ends_at TEXT,
      published INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS donations (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      project_id TEXT,
      donor_email TEXT,
      anonymous INTEGER NOT NULL DEFAULT 0,
      amount_cents INTEGER NOT NULL,
      frequency TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      helloasso_checkout_intent_id TEXT UNIQUE,
      helloasso_order_id TEXT UNIQUE,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS networking_profiles (
      user_id TEXT PRIMARY KEY,
      city TEXT,
      sector TEXT,
      skills TEXT NOT NULL DEFAULT '[]',
      visibility TEXT NOT NULL DEFAULT '{}',
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS networking_requests (
      id TEXT PRIMARY KEY,
      requester_id TEXT NOT NULL,
      recipient_id TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(requester_id, recipient_id)
    );

    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      type TEXT NOT NULL,
      title TEXT NOT NULL,
      body TEXT,
      read_at TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS device_tokens (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      token TEXT NOT NULL UNIQUE,
      platform TEXT NOT NULL,
      preferences TEXT NOT NULL DEFAULT '{}',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS consents (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      purpose TEXT NOT NULL,
      granted INTEGER NOT NULL,
      recorded_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  `);
    // Seed default demo data if empty
    const projectCount = sqlite.prepare('SELECT count(*) as count FROM projects').get();
    if (projectCount.count === 0) {
        console.log('[Database] Seeding initial projects, news, events, and demo accounts...');
        // Default User
        const hash = bcrypt.hashSync('Password123!', 10);
        sqlite.prepare(`
      INSERT INTO users (id, email, first_name, last_name, country, password_hash, directory_visible)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `).run('user_karim_01', 'karim.benamor@diaspora.tn', 'Karim', 'Ben Amor', 'France', hash);
        sqlite.prepare(`
      INSERT INTO users (id, email, first_name, last_name, country, password_hash, directory_visible)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `).run('user_sonia_02', 'sonia.trabelsi@diaspora.tn', 'Sonia', 'Trabelsi', 'Tunisie', hash);
        sqlite.prepare(`
      INSERT INTO users (id, email, first_name, last_name, country, password_hash, directory_visible)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `).run('user_mehdi_03', 'mehdi.fakhfakh@diaspora.tn', 'Mehdi', 'Fakhfakh', 'Canada', hash);
        // Networking Profiles
        sqlite.prepare(`
      INSERT INTO networking_profiles (user_id, city, sector, skills, visibility)
      VALUES (?, ?, ?, ?, ?)
    `).run('user_karim_01', 'Paris', 'Tech & Investissement', JSON.stringify(['Fintech', 'AgriTech', 'Mentorat']), JSON.stringify({ visible: true }));
        sqlite.prepare(`
      INSERT INTO networking_profiles (user_id, city, sector, skills, visibility)
      VALUES (?, ?, ?, ?, ?)
    `).run('user_sonia_02', 'Tunis / Djerba', 'Développement Régional', JSON.stringify(['Partenariats Public-Privé', 'FIPA', 'Gouvernance']), JSON.stringify({ visible: true }));
        sqlite.prepare(`
      INSERT INTO networking_profiles (user_id, city, sector, skills, visibility)
      VALUES (?, ?, ?, ?, ?)
    `).run('user_mehdi_03', 'Montréal', 'Ingénierie Environnementale', JSON.stringify(['Hydrologie', 'Énergie Solaire', 'Traitement des Eaux']), JSON.stringify({ visible: true }));
        // Membership for Karim
        sqlite.prepare(`
      INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, motivation, status, submitted_at, paid_at, expires_at)
      VALUES (?, ?, ?, ?, ?, ?, 'active', datetime('now'), datetime('now'), '2027-12-31')
    `).run('mem_2026_0042', 'user_karim_01', 'benefactor', 10000, 'Originaire de Houmt Souk', 'Contribuer activement au rayonnement de Djerba');
        // Projects
        sqlite.prepare(`
      INSERT INTO projects (id, title, category, summary, body, location, progress, target_cents, raised_cents, featured, published)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    `).run('proj_guellala_01', 'Sauvegarde des Potiers Traditionnels de Guellala', 'Patrimoine', 'Modernisation respectueuse des ateliers ancestraux et mise en place d\'une filière de distribution artisanale internationale.', 'Le village de Guellala abrite des millénaires d\'histoire potière. Ce projet finance des fours écologiques à haute efficacité thermique et un espace muséal coopératif pour préserver et pérenniser ce savoir-faire.', 'Guellala, Djerba', 0.68, 2500000, 1700000, 1);
        sqlite.prepare(`
      INSERT INTO projects (id, title, category, summary, body, location, progress, target_cents, raised_cents, featured, published)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    `).run('proj_ecologie_02', 'Restauration de la Réserve Naturelle de Ras Rmel', 'Écologie', 'Protection des lagunes des flamants roses, nettoyage citoyen des côtes et balisage éco-responsable des sentiers maritimes.', 'La presqu\'île des flamants roses est l\'un des écosystèmes les plus précieux de la Méditerranée. Ce programme déploie des barrières naturelles de protection des dunes et sensibilise les visiteurs.', 'Ras Rmel, Djerba', 0.82, 1500000, 1230000, 1);
        sqlite.prepare(`
      INSERT INTO projects (id, title, category, summary, body, location, progress, target_cents, raised_cents, featured, published)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    `).run('proj_education_03', 'Bibliothèque Digitale & FabLab Jeunesse', 'Éducation', 'Équipement numérique de trois écoles rurales et initiation au code et à la robotique pour 400 élèves djerbiens.', 'Fourniture de tablettes éducatives, accès internet satellitaire sécurisé et ateliers animés par des ingénieurs de la diaspora bénévole.', 'Ajim & Midoun, Djerba', 0.45, 2000000, 900000, 0);
        // News
        sqlite.prepare(`
      INSERT INTO news (id, title, excerpt, body, category, published)
      VALUES (?, ?, ?, ?, ?, 1)
    `).run('news_01', 'L\'UNESCO salue les initiatives citoyennes de préservation insulaire', 'Le comité de suivi du patrimoine mondial souligne l\'impact des chantiers participatifs menés par les associations et la diaspora à Djerba.', 'Le classement de l\'île de Djerba au patrimoine mondial de l\'UNESCO en 2023 franchit une nouvelle étape grâce à la mobilisation des citoyens.', 'Patrimoine');
        sqlite.prepare(`
      INSERT INTO news (id, title, excerpt, body, category, published)
      VALUES (?, ?, ?, ?, ?, 1)
    `).run('news_02', 'Préparatifs officiels du Sommet International de la Diaspora 2026', 'Plus de 350 délégués, investisseurs et personnalités culturelles sont attendus à Houmt Souk du 24 au 26 octobre 2026.', 'Le programme plénier abordera le guichet unique d\'investissement, l\'écologie insulaire et les coopérations technologiques.', 'Congrès');
        // Events
        sqlite.prepare(`
      INSERT INTO events (id, title, summary, location, starts_at, ends_at, published)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `).run('evt_summit_2026', 'Sommet International de la Diaspora 2026', 'Trois journées de conférences, tables rondes d\'investisseurs et rencontres institutionnelles.', 'Houmt Souk, Djerba', '2026-10-24 09:00:00', '2026-10-26 18:00:00');
        sqlite.prepare(`
      INSERT INTO events (id, title, summary, location, starts_at, ends_at, published)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `).run('evt_ag_statutaire', 'Assemblée Générale Statutaire ADP 2026', 'Vote des bilans financiers, renouvellement du bureau exécutif et validation des budgets de projets.', 'Midoun, Djerba & Diffusion Live', '2026-11-14 14:00:00', '2026-11-14 18:00:00');
        // Notifications
        sqlite.prepare(`
      INSERT INTO notifications (id, user_id, type, title, body)
      VALUES (?, ?, ?, ?, ?)
    `).run('notif_01', 'user_karim_01', 'summit', 'Votre e-Pass pour le Sommet 2026 est disponible', 'Accédez à votre QR code certifié dans l\'onglet e-Pass pour l\'accès prioritaire aux conférences.');
        sqlite.prepare(`
      INSERT INTO notifications (id, user_id, type, title, body)
      VALUES (?, ?, ?, ?, ?)
    `).run('notif_02', 'user_karim_01', 'project', 'Projet Potiers de Guellala : palier des 65% atteint !', 'Grâce à votre soutien, les commandes des nouveaux fours céramiques écologiques ont été passées.');
    }
    return {
        async query(sql, params = []) {
            // Translate Postgres parameters ($1, $2, ...) to SQLite (?)
            let translated = sql.replace(/\$(\d+)/g, '?');
            // Translate Postgres-specific functions & syntax
            translated = translated.replace(/NOW\(\)\s*\+\s*INTERVAL\s*'(\d+)\s*days'/gi, "datetime('now', '+$1 days')");
            translated = translated.replace(/NOW\(\)/gi, "datetime('now')");
            translated = translated.replace(/FOR\s+UPDATE/gi, "");
            translated = translated.replace(/gen_random_uuid\(\)/gi, "(lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-a' || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6))))");
            translated = translated.replace(/ILIKE/gi, 'LIKE');
            translated = translated.replace(/\bTRUE\b/g, '1');
            translated = translated.replace(/\bFALSE\b/g, '0');
            translated = translated.replace(/ANY\(n\.skills\)/g, "n.skills LIKE '%' || ? || '%'");
            // Normalize parameters
            const mappedParams = params.map(p => {
                if (typeof p === 'boolean')
                    return p ? 1 : 0;
                if (Array.isArray(p))
                    return JSON.stringify(p);
                return p;
            });
            try {
                const trimmed = translated.trim();
                const isSelect = trimmed.toUpperCase().startsWith('SELECT') || trimmed.includes('RETURNING');
                if (isSelect) {
                    const stmt = sqlite.prepare(translated);
                    const rows = stmt.all(...mappedParams);
                    // Normalize boolean fields if needed
                    for (const row of rows) {
                        if (row && typeof row === 'object') {
                            if (row.directoryVisible !== undefined)
                                row.directoryVisible = Boolean(row.directoryVisible);
                            if (row.anonymous !== undefined)
                                row.anonymous = Boolean(row.anonymous);
                            if (row.visible !== undefined)
                                row.visible = Boolean(row.visible);
                            if (row.skills && typeof row.skills === 'string') {
                                try {
                                    row.skills = JSON.parse(row.skills);
                                }
                                catch { /* keep */ }
                            }
                            if (row.visibility && typeof row.visibility === 'string') {
                                try {
                                    row.visibility = JSON.parse(row.visibility);
                                }
                                catch { /* keep */ }
                            }
                        }
                    }
                    return { rows, rowCount: rows.length };
                }
                else {
                    const stmt = sqlite.prepare(translated);
                    const info = stmt.run(...mappedParams);
                    return { rows: [], rowCount: Number(info.changes) };
                }
            }
            catch (err) {
                console.error('[SQLite Query Error]', { sql: translated, params: mappedParams, err });
                throw err;
            }
        },
        async connect() {
            return {
                query: (sql, params) => activeDb.query(sql, params),
                release: () => { }
            };
        }
    };
}
// Initializer: prefers PostgreSQL if reachable, falls back seamlessly to SQLite
const pgPool = new Pool({
    connectionString: env.DATABASE_URL,
    connectionTimeoutMillis: 1500,
    max: 5,
});
export const db = {
    async query(sql, params = []) {
        if (activeDb) {
            return activeDb.query(sql, params);
        }
        try {
            // Probe PostgreSQL
            const client = await pgPool.connect();
            client.release();
            activeDb = pgPool;
            console.log('[Database] Connected to PostgreSQL successfully.');
            return activeDb.query(sql, params);
        }
        catch (error) {
            if (!env.ALLOW_SQLITE_FALLBACK) {
                console.error('[Database] PostgreSQL connection failed and SQLite fallback is disabled.');
                throw error;
            }
            console.warn('[Database] PostgreSQL unreachable. Using SQLite only because ALLOW_SQLITE_FALLBACK=true.');
            activeDb = createSqliteDb();
            return activeDb.query(sql, params);
        }
    },
    async connect() {
        if (!activeDb) {
            await this.query('SELECT 1');
        }
        return activeDb.connect();
    }
};
export async function databaseHealth() {
    await db.query('SELECT 1');
    return activeDb === pgPool ? 'postgresql' : 'sqlite';
}
