const { DatabaseSync } = require('node:sqlite');
const path = require('node:path');
const bcrypt = require('bcryptjs');

const dbPath = path.resolve(__dirname, 'adp.sqlite');
console.log('Target SQLite Database:', dbPath);

const db = new DatabaseSync(dbPath);

console.log('Seeding authentic ADP Djerba database...');

const hash = bcrypt.hashSync('Password123!', 10);

// 1. USERS
db.exec(`DELETE FROM users;`);
const insertUser = db.prepare(`
  INSERT INTO users (id, email, first_name, last_name, country, password_hash, directory_visible, created_at)
  VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
`);

insertUser.run('usr_slim_001', 'slim.benamor@djerba.tn', 'Slim', 'Ben Amor', 'Tunisie', hash, 1);
insertUser.run('usr_karim_002', 'karim.benamor@diaspora.tn', 'Karim', 'Ben Amor', 'France', hash, 1);
insertUser.run('usr_myriam_003', 'myriam.trabelsi@djerba.tn', 'Dr. Myriam', 'Trabelsi', 'Tunisie', hash, 1);
insertUser.run('usr_kamel_004', 'kamel.ghedamsi@djerba.tn', 'Kamel', 'Ghedamsi', 'Tunisie', hash, 1);
insertUser.run('usr_nadia_005', 'nadia.benyoussef@diaspora.tn', 'Nadia', 'Ben Youssef', 'France', hash, 1);
insertUser.run('usr_tarek_006', 'tarek.bouzguenda@diaspora.tn', 'Tarek', 'Bouzguenda', 'France', hash, 1);
insertUser.run('usr_amel_007', 'amel.haddad@djerba.tn', 'Amel', 'Haddad', 'Tunisie', hash, 1);
insertUser.run('usr_sonia_008', 'sonia.trabelsi@diaspora.tn', 'Sonia', 'Trabelsi', 'Tunisie', hash, 1);
insertUser.run('usr_mehdi_009', 'mehdi.fakhfakh@diaspora.tn', 'Mehdi', 'Fakhfakh', 'Canada', hash, 1);

console.log('✓ 9 Users inserted');

// 2. MEMBERSHIPS & E-PASS
db.exec(`DELETE FROM memberships;`);
const insertMembership = db.prepare(`
  INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, motivation, status, submitted_at, paid_at, expires_at, created_at)
  VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'), ?, datetime('now'))
`);

insertMembership.run('ADP-2024-0482', 'usr_slim_001', 'benefactor', 10000, 'Originaire de Houmt Souk', 'Soutien prioritaire aux initiatives de l’île', 'active', '2026-12-31');
insertMembership.run('ADP-2025-0104', 'usr_karim_002', 'diaspora', 5000, 'Diaspora Paris / Houmt Souk', 'Accompagnement tech et mentorat des jeunes', 'active', '2026-12-31');
insertMembership.run('ADP-2023-0001', 'usr_myriam_003', 'benefactor', 10000, 'Présidente ADP, Midoun', 'Présidence et gouvernance de l’association', 'active', '2027-12-31');
insertMembership.run('ADP-2024-0012', 'usr_kamel_004', 'individual', 3000, 'Architecte, Houmt Souk', 'Expertise patrimoine mondial UNESCO', 'active', '2026-12-31');
insertMembership.run('ADP-2025-0210', 'usr_nadia_005', 'diaspora', 5000, 'Diaspora Paris / Guellala', 'Transition écologique et projets solaires', 'active', '2026-12-31');

console.log('✓ 5 Memberships & e-Pass active');

// 3. NETWORKING PROFILES
db.exec(`DELETE FROM networking_profiles;`);
const insertProfile = db.prepare(`
  INSERT INTO networking_profiles (user_id, city, sector, skills, visibility, updated_at)
  VALUES (?, ?, ?, ?, ?, datetime('now'))
`);

insertProfile.run('usr_slim_001', 'Houmt Souk / Paris', 'Directeur de Projets & Stratégie', JSON.stringify(['Gouvernance', 'Financement', 'Partenariats']), JSON.stringify({ visible: true }));
insertProfile.run('usr_myriam_003', 'Tunis / Djerba', 'Santé Publique & Gouvernance', JSON.stringify(['Santé', 'Gouvernance', 'Solidarité']), JSON.stringify({ visible: true }));
insertProfile.run('usr_kamel_004', 'Houmt Souk', 'Architecture du Patrimoine', JSON.stringify(['UNESCO', 'Urbanisme', 'Conservation']), JSON.stringify({ visible: true }));
insertProfile.run('usr_nadia_005', 'Paris, France', 'Ingénierie Énergie Solaire', JSON.stringify(['Photovoltaïque', 'R&D', 'Écologie']), JSON.stringify({ visible: true }));
insertProfile.run('usr_tarek_006', 'Lyon, France', 'Entrepreneur Tech & Diaspora', JSON.stringify(['Venture Capital', 'IA', 'Fintech']), JSON.stringify({ visible: true }));
insertProfile.run('usr_amel_007', 'Midoun', 'Éducation & Éco-citoyenneté', JSON.stringify(['Éducation', 'Jeunesse', 'Sensibilisation']), JSON.stringify({ visible: true }));
insertProfile.run('usr_karim_002', 'Paris', 'Tech & Investissement', JSON.stringify(['Fintech', 'AgriTech', 'Mentorat']), JSON.stringify({ visible: true }));
insertProfile.run('usr_sonia_008', 'Tunis / Djerba', 'Développement Régional', JSON.stringify(['Partenariats Public-Privé', 'FIPA', 'Gouvernance']), JSON.stringify({ visible: true }));
insertProfile.run('usr_mehdi_009', 'Montréal', 'Ingénierie Environnementale', JSON.stringify(['Hydrologie', 'Énergie Solaire', 'Traitement des Eaux']), JSON.stringify({ visible: true }));

console.log('✓ 9 Networking Profiles inserted');

// 4. PROJECTS
db.exec(`DELETE FROM projects;`);
const insertProject = db.prepare(`
  INSERT INTO projects (id, title, category, summary, body, location, progress, target_cents, raised_cents, featured, published, created_at)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, datetime('now'))
`);

insertProject.run(
  'prj-01',
  'Restauration des Menzeh Traditionnels',
  'Patrimoine',
  'Préservation architecturale des habitations traditionnelles et huileries souterraines de Djerba.',
  'L’inscription de Djerba au Patrimoine Mondial de l’UNESCO en septembre 2023 met en lumière le système d’occupation du sol unique des Menzeh djerbiens. Ce projet finance la restauration selon les techniques vernaculaires de chaux aérienne et de voûtes traditionnelles.',
  'Houmt Souk & Sedghiane',
  0.74,
  2500000,
  1845000,
  1
);

insertProject.run(
  'prj-02',
  'Protection de la lagune des flamants roses',
  'Écologie',
  'Campagne de nettoyage, pose de nichoirs et balisage éco-responsable à Ras Rmel pour sauvegarder la biodiversité.',
  'La presqu’île de Ras Rmel abrite chaque hiver des milliers de flamants roses et d’oiseaux migrateurs. L’action citoyenne ADP organise le ramassage des plastiques marins, la sensibilisation des bateliers et l’installation d’observatoires ornithologiques discrets.',
  'Ras Rmel, Djerba',
  0.82,
  1000000,
  820000,
  1
);

insertProject.run(
  'prj-03',
  'FabLab & Bourses Numériques pour les Jeunes',
  'Éducation',
  'Équipement d’un espace de formation technologique, codage et robotique pour les collégiens de Midoun.',
  'Connecter la jeunesse insulaire aux métiers d’avenir. Ce FabLab dote les jeunes de Midoun d’imprimantes 3D, de kits IoT et d’ordinateurs, avec des sessions de mentorat hebdomadaires assurées par les ingénieurs de la diaspora.',
  'Midoun, Djerba',
  0.97,
  1500000,
  1460000,
  0
);

insertProject.run(
  'prj-04',
  'Valorisation des Potiers de Guellala',
  'Économie',
  'Transition vers des fours solaires haute performance et création d’un circuit éco-responsable équitable.',
  'Guellala est le berceau millénaire de la poterie djerbienne. Ce projet soutient les maîtres artisans face à la hausse des coûts énergétiques par des fours solaires hybrides et une coopérative équitable.',
  'Guellala, Djerba',
  0.525,
  1200000,
  630000,
  1
);

insertProject.run(
  'prj-05',
  'Unité Pilote de Dessalement Solaire Villageoise',
  'Écologie',
  'Station autonome d’osmose inverse alimentée par énergie solaire pour alimenter les oliveraies et familles isolées.',
  'Face au stress hydrique insulaire, cette unité produit 15 000 litres d’eau douce par jour sans aucune émission carbone, protégeant les nappes phréatiques et l’agriculture durable.',
  'Ajim & Beni Maaguel',
  0.63,
  3500000,
  2200000,
  0
);

insertProject.run(
  'prj-06',
  'Sauvegarde des Mosquées Fortifiées & Souterraines',
  'Patrimoine',
  'Consolidation architecturale et parcours de visite patrimoniale des mosquées emblématiques de Fadhloun et Sidi Jmour.',
  'Les mosquées défensives de Djerba témoignent d’un génie défensif et spirituel singulier. Ce projet restaure les façades blanchies à la chaux, les citernes pluviales collectives (Majel) et édite des guides d’interprétation.',
  'Sidi Jmour & Midoun',
  0.675,
  2000000,
  1350000,
  1
);

console.log('✓ 6 Projects inserted');

// 5. NEWS
db.exec(`DELETE FROM news;`);
const insertNews = db.prepare(`
  INSERT INTO news (id, title, excerpt, body, category, published, created_at)
  VALUES (?, ?, ?, ?, ?, 1, datetime('now', ?))
`);

insertNews.run(
  'news-01',
  'Inscription de Djerba à l’UNESCO : les nouvelles retombées',
  'La reconnaissance mondiale accélère les projets de préservation et ouvre de nouveaux partenariats internationaux.',
  'Trois ans après l’inscription officielle du paysage culturel de Djerba sur la liste du Patrimoine Mondial de l’UNESCO en septembre 2023, le comité de suivi dresse un bilan élogieux. Les 24 monuments protégés bénéficient désormais d’un plan de gestion intégré garantissant l’harmonie entre préservation des traditions et accueil respectueux.',
  'Actualité',
  '-2 days'
);

insertNews.run(
  'news-02',
  'Bilan de la saison estivale 2026 : 40 tonnes de déchets collectés',
  'Un engagement massif de la diaspora et des habitants pour un littoral préservé et zéro plastique à Ras Rmel.',
  'Grâce à la mobilisation de plus de 600 bénévoles tout au long de l’été 2026, l’initiative citoyenne « Djerba Île Propre » a permis de nettoyer 35 kilomètres de côtes. Les déchets plastiques ont été acheminés vers des filières de recyclage locales.',
  'Écologie',
  '-9 days'
);

insertNews.run(
  'news-03',
  'Lancement du Forum Diaspora & Entrepreneuriat à Houmt Souk',
  'Rendez-vous à Houmt Souk en décembre prochain pour connecter porteurs de projets insulaires et investisseurs de la diaspora.',
  'Le pôle économique de l’ADP annonce la tenue du Forum annuel de l’Entrepreneuriat en marge du Sommet Diaspora 2026. 40 startups et coopératives artisanales pitcheront devant des Business Angels djerbiens venus d’Europe et d’Amérique du Nord.',
  'Événement',
  '-22 days'
);

insertNews.run(
  'news-04',
  'Inauguration du premier four céramique solaire à Guellala',
  'Une avancée majeure qui préserve la cuisson traditionnelle de l’argile tout en réduisant de 75% l’empreinte carbone.',
  'En partenariat avec des mécènes de l’ADP, le village de Guellala célèbre la mise en service du premier four céramique solaire hybride, fruit d’un transfert de technologie porté par des ingénieurs de la diaspora.',
  'Économie',
  '-30 days'
);

console.log('✓ 4 News inserted');

// 6. EVENTS
db.exec(`DELETE FROM events;`);
const insertEvent = db.prepare(`
  INSERT INTO events (id, title, summary, location, starts_at, ends_at, published, created_at)
  VALUES (?, ?, ?, ?, ?, ?, 1, datetime('now'))
`);

insertEvent.run(
  'evt-01',
  'Assemblée Générale Annuelle 2026',
  'Vote des bilans financiers, renouvellement du bureau exécutif et validation des budgets de projets.',
  'Houmt Souk & Visioconférence',
  '2026-10-12 14:30:00',
  '2026-10-12 18:00:00'
);

insertEvent.run(
  'evt-02',
  'Rencontre Réseau Diaspora Paris',
  'Soirée d’échange et networking entre cadres, entrepreneurs et étudiants de la diaspora djerbienne en Île-de-France.',
  'Maison de la Tunisie, Paris',
  '2026-10-24 19:00:00',
  '2026-10-24 22:00:00'
);

insertEvent.run(
  'evt-03',
  'Atelier de plantation d’oliviers',
  'Journée de reboisement solidaire et sensibilisation à la préservation des sols insulaires avec les écoles.',
  'Ajim, Djerba',
  '2026-11-07 09:00:00',
  '2026-11-07 13:00:00'
);

insertEvent.run(
  'evt-04',
  'Djerba Diaspora Summit 2026',
  'Trois journées de conférences plénières, hackathon jeunesse et forum d’investissement pour l’avenir de l’île.',
  'Houmt Souk & Djerba Explore',
  '2026-12-18 09:00:00',
  '2026-12-20 18:00:00'
);

console.log('✓ 4 Events inserted');

// 7. NOTIFICATIONS
db.exec(`DELETE FROM notifications;`);
const insertNotif = db.prepare(`
  INSERT INTO notifications (id, user_id, type, title, body, created_at)
  VALUES (?, ?, ?, ?, ?, datetime('now'))
`);

insertNotif.run('notif-1', 'usr_slim_001', 'donation', 'Don bien reçu !', 'Merci pour votre don de 50€ au projet Lagune de Ras Rmel.');
insertNotif.run('notif-2', 'usr_slim_001', 'epass', 'Votre e-Pass est actif', 'Votre carte membre 2026 a été renouvelée avec succès avec certification cryptographique.');
insertNotif.run('notif-3', 'usr_slim_001', 'project', 'Nouveau projet en ligne', 'Découvrez le FabLab pour les jeunes de Midoun et participez au parrainage.');

console.log('✓ 3 Notifications inserted');

console.log('ADP Real Database Seeding Completed Successfully!');
