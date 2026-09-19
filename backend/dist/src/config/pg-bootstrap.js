import bcrypt from 'bcryptjs';
/**
 * Idempotent PostgreSQL schema bootstrap + demo seed.
 *
 * Runs automatically on the first successful PostgreSQL connection so that a
 * freshly provisioned database (e.g. a new Neon/Vercel Postgres instance wired
 * through DATABASE_URL) is immediately usable — including on serverless hosts
 * where a manual migration step is impossible.
 *
 * Every statement is safe to run repeatedly and concurrently from multiple
 * serverless instances: enum creation is guarded, tables/columns/indexes use
 * IF NOT EXISTS, and seed rows use fixed UUIDs with ON CONFLICT DO NOTHING.
 */
const SCHEMA_SQL = `
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN
  CREATE TYPE membership_status AS ENUM ('draft','submitted','paymentConfirmed','pendingReview','active','rejected','expired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE donation_frequency AS ENUM ('oneOff','monthly');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE donation_status AS ENUM ('pending','confirmed','failed','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  country VARCHAR(100) NOT NULL,
  password_hash TEXT NOT NULL,
  google_sub VARCHAR(64),
  directory_visible BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  plan VARCHAR(40) NOT NULL,
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  djerba_connection TEXT,
  motivation TEXT,
  status membership_status NOT NULL DEFAULT 'draft',
  submitted_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  expires_at DATE,
  rejection_reason TEXT,
  helloasso_checkout_intent_id VARCHAR(128) UNIQUE,
  helloasso_order_id VARCHAR(128) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  category VARCHAR(60) NOT NULL,
  summary TEXT NOT NULL,
  body TEXT,
  location VARCHAR(200) NOT NULL DEFAULT 'Djerba',
  progress NUMERIC(5,4) NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 1),
  target_cents INTEGER,
  raised_cents INTEGER NOT NULL DEFAULT 0,
  featured BOOLEAN NOT NULL DEFAULT FALSE,
  published BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS news (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(240) NOT NULL,
  excerpt TEXT NOT NULL,
  body TEXT,
  category VARCHAR(60),
  cover_image_url TEXT,
  published BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(240) NOT NULL,
  summary TEXT,
  location VARCHAR(240),
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  published BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  project_id UUID REFERENCES projects(id),
  donor_email VARCHAR(255),
  anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  frequency donation_frequency NOT NULL,
  status donation_status NOT NULL DEFAULT 'pending',
  helloasso_checkout_intent_id VARCHAR(128) UNIQUE,
  helloasso_order_id VARCHAR(128) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS networking_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  city VARCHAR(100),
  sector VARCHAR(120),
  skills TEXT[] NOT NULL DEFAULT '{}',
  visibility JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS networking_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES users(id),
  recipient_id UUID NOT NULL REFERENCES users(id),
  status VARCHAR(16) NOT NULL CHECK (status IN ('pending','accepted','declined')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(requester_id, recipient_id)
);

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  type VARCHAR(50) NOT NULL,
  title VARCHAR(240) NOT NULL,
  body TEXT,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  token VARCHAR(255) NOT NULL UNIQUE,
  platform VARCHAR(20) NOT NULL,
  preferences JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  purpose VARCHAR(64) NOT NULL,
  granted BOOLEAN NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS helloasso_webhook_events (
  event_id VARCHAR(128) PRIMARY KEY,
  event_type VARCHAR(80) NOT NULL,
  payload JSONB NOT NULL,
  received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ,
  processing_error TEXT
);

CREATE TABLE IF NOT EXISTS data_subject_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('export','erasure','rectification')),
  status VARCHAR(20) NOT NULL DEFAULT 'requested' CHECK (status IN ('requested','processing','completed','rejected')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ,
  processing_note TEXT
);

-- Columns/patches for databases originally created from older migrations.
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_sub VARCHAR(64);
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS djerba_connection TEXT;
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS motivation TEXT;
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS helloasso_checkout_intent_id VARCHAR(128);
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS helloasso_order_id VARCHAR(128);
ALTER TABLE donations ADD COLUMN IF NOT EXISTS helloasso_checkout_intent_id VARCHAR(128);
ALTER TABLE donations ADD COLUMN IF NOT EXISTS helloasso_order_id VARCHAR(128);

CREATE UNIQUE INDEX IF NOT EXISTS users_google_sub_idx ON users (google_sub) WHERE google_sub IS NOT NULL;
CREATE INDEX IF NOT EXISTS memberships_user_idx ON memberships(user_id, status);
CREATE INDEX IF NOT EXISTS memberships_checkout_intent_idx ON memberships(helloasso_checkout_intent_id) WHERE helloasso_checkout_intent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS donations_user_idx ON donations(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS donations_checkout_intent_idx ON donations(helloasso_checkout_intent_id) WHERE helloasso_checkout_intent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS notifications_user_idx ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS helloasso_webhook_pending_idx ON helloasso_webhook_events(received_at) WHERE processed_at IS NULL;
CREATE INDEX IF NOT EXISTS data_subject_requests_user_idx ON data_subject_requests(user_id, requested_at DESC);
`;
// Deterministic UUIDs so concurrent bootstraps converge instead of colliding.
const U_KARIM = '00000000-0000-4000-8000-000000000001';
const U_SONIA = '00000000-0000-4000-8000-000000000002';
const U_MEHDI = '00000000-0000-4000-8000-000000000003';
const M_KARIM = '00000000-0000-4000-8000-00000000a042';
const P_GUELLALA = '00000000-0000-4000-8000-00000000b001';
const P_ECOLOGIE = '00000000-0000-4000-8000-00000000b002';
const P_EDUCATION = '00000000-0000-4000-8000-00000000b003';
const N_NEWS_01 = '00000000-0000-4000-8000-00000000c001';
const N_NEWS_02 = '00000000-0000-4000-8000-00000000c002';
const E_SUMMIT = '00000000-0000-4000-8000-00000000d001';
const E_AG = '00000000-0000-4000-8000-00000000d002';
const NOTIF_01 = '00000000-0000-4000-8000-00000000e001';
const NOTIF_02 = '00000000-0000-4000-8000-00000000e002';
async function seedDemoData(client) {
    const { rows } = await client.query('SELECT COUNT(*)::int AS count FROM users');
    if (rows[0].count > 0)
        return false;
    console.log('[Database] Seeding initial projects, news, events, and demo accounts (PostgreSQL)...');
    const hash = bcrypt.hashSync('Password123!', 10);
    const insertUser = (id, email, first, last, country) => client.query('INSERT INTO users (id, email, first_name, last_name, country, password_hash, directory_visible) VALUES ($1,$2,$3,$4,$5,$6,TRUE) ON CONFLICT DO NOTHING', [id, email, first, last, country, hash]);
    await insertUser(U_KARIM, 'karim.benamor@diaspora.tn', 'Karim', 'Ben Amor', 'France');
    await insertUser(U_SONIA, 'sonia.trabelsi@diaspora.tn', 'Sonia', 'Trabelsi', 'Tunisie');
    await insertUser(U_MEHDI, 'mehdi.fakhfakh@diaspora.tn', 'Mehdi', 'Fakhfakh', 'Canada');
    const insertProfile = (userId, city, sector, skills) => client.query('INSERT INTO networking_profiles (user_id, city, sector, skills, visibility) VALUES ($1,$2,$3,$4,$5::jsonb) ON CONFLICT DO NOTHING', [userId, city, sector, skills, JSON.stringify({ visible: true })]);
    await insertProfile(U_KARIM, 'Paris', 'Tech & Investissement', ['Fintech', 'AgriTech', 'Mentorat']);
    await insertProfile(U_SONIA, 'Tunis / Djerba', 'Développement Régional', ['Partenariats Public-Privé', 'FIPA', 'Gouvernance']);
    await insertProfile(U_MEHDI, 'Montréal', 'Ingénierie Environnementale', ['Hydrologie', 'Énergie Solaire', 'Traitement des Eaux']);
    await client.query(`INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, motivation, status, submitted_at, paid_at, expires_at)
     VALUES ($1,$2,'benefactor',10000,$3,$4,'active',NOW(),NOW(),'2027-12-31') ON CONFLICT DO NOTHING`, [M_KARIM, U_KARIM, 'Originaire de Houmt Souk', 'Contribuer activement au rayonnement de Djerba']);
    const insertProject = (id, title, category, summary, body, location, progress, target, raised, featured) => client.query(`INSERT INTO projects (id, title, category, summary, body, location, progress, target_cents, raised_cents, featured, published)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,TRUE) ON CONFLICT DO NOTHING`, [id, title, category, summary, body, location, progress, target, raised, featured]);
    await insertProject(P_GUELLALA, 'Sauvegarde des Potiers Traditionnels de Guellala', 'Patrimoine', "Modernisation respectueuse des ateliers ancestraux et mise en place d'une filière de distribution artisanale internationale.", "Le village de Guellala abrite des millénaires d'histoire potière. Ce projet finance des fours écologiques à haute efficacité thermique et un espace muséal coopératif pour préserver et pérenniser ce savoir-faire.", 'Guellala, Djerba', 0.68, 2500000, 1700000, true);
    await insertProject(P_ECOLOGIE, 'Restauration de la Réserve Naturelle de Ras Rmel', 'Écologie', 'Protection des lagunes des flamants roses, nettoyage citoyen des côtes et balisage éco-responsable des sentiers maritimes.', "La presqu'île des flamants roses est l'un des écosystèmes les plus précieux de la Méditerranée. Ce programme déploie des barrières naturelles de protection des dunes et sensibilise les visiteurs.", 'Ras Rmel, Djerba', 0.82, 1500000, 1230000, true);
    await insertProject(P_EDUCATION, 'Bibliothèque Digitale & FabLab Jeunesse', 'Éducation', 'Équipement numérique de trois écoles rurales et initiation au code et à la robotique pour 400 élèves djerbiens.', 'Fourniture de tablettes éducatives, accès internet satellitaire sécurisé et ateliers animés par des ingénieurs de la diaspora bénévole.', 'Ajim & Midoun, Djerba', 0.45, 2000000, 900000, false);
    const insertNews = (id, title, excerpt, body, category) => client.query('INSERT INTO news (id, title, excerpt, body, category, published) VALUES ($1,$2,$3,$4,$5,TRUE) ON CONFLICT DO NOTHING', [id, title, excerpt, body, category]);
    await insertNews(N_NEWS_01, "L'UNESCO salue les initiatives citoyennes de préservation insulaire", "Le comité de suivi du patrimoine mondial souligne l'impact des chantiers participatifs menés par les associations et la diaspora à Djerba.", "Le classement de l'île de Djerba au patrimoine mondial de l'UNESCO en 2023 franchit une nouvelle étape grâce à la mobilisation des citoyens.", 'Patrimoine');
    await insertNews(N_NEWS_02, 'Préparatifs officiels du Sommet International de la Diaspora 2026', 'Plus de 350 délégués, investisseurs et personnalités culturelles sont attendus à Houmt Souk du 24 au 26 octobre 2026.', "Le programme plénier abordera le guichet unique d'investissement, l'écologie insulaire et les coopérations technologiques.", 'Congrès');
    const insertEvent = (id, title, summary, location, startsAt, endsAt) => client.query('INSERT INTO events (id, title, summary, location, starts_at, ends_at, published) VALUES ($1,$2,$3,$4,$5::timestamptz,$6::timestamptz,TRUE) ON CONFLICT DO NOTHING', [id, title, summary, location, startsAt, endsAt]);
    await insertEvent(E_SUMMIT, 'Sommet International de la Diaspora 2026', "Trois journées de conférences, tables rondes d'investisseurs et rencontres institutionnelles.", 'Houmt Souk, Djerba', '2026-10-24 09:00:00+01', '2026-10-26 18:00:00+01');
    await insertEvent(E_AG, 'Assemblée Générale Statutaire ADP 2026', 'Vote des bilans financiers, renouvellement du bureau exécutif et validation des budgets de projets.', 'Midoun, Djerba & Diffusion Live', '2026-11-14 14:00:00+01', '2026-11-14 18:00:00+01');
    const insertNotification = (id, userId, type, title, body) => client.query('INSERT INTO notifications (id, user_id, type, title, body) VALUES ($1,$2,$3,$4,$5) ON CONFLICT DO NOTHING', [id, userId, type, title, body]);
    await insertNotification(NOTIF_01, U_KARIM, 'summit', 'Votre e-Pass pour le Sommet 2026 est disponible', "Accédez à votre QR code certifié dans l'onglet e-Pass pour l'accès prioritaire aux conférences.");
    await insertNotification(NOTIF_02, U_KARIM, 'project', 'Projet Potiers de Guellala : palier des 65% atteint !', 'Grâce à votre soutien, les commandes des nouveaux fours céramiques écologiques ont été passées.');
    return true;
}
export async function ensurePostgresSchema(pool) {
    await pool.query(SCHEMA_SQL);
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const seeded = await seedDemoData(client);
        await client.query('COMMIT');
        return { seeded };
    }
    catch (error) {
        await client.query('ROLLBACK');
        throw error;
    }
    finally {
        client.release();
    }
}
