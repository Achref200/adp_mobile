/**
 * ADP State Store
 * Manages user authentication, demo & live data, and persistent state.
 */

class AdpStore {
  constructor() {
    this.storageKey = 'adp_app_state_v1';
    this.listeners = [];
    this.state = this.loadState();
  }

  getDefaultState() {
    return {
      isAuthenticated: true,
      currentUser: {
        id: 'usr_djerba_001',
        firstName: 'Slim',
        lastName: 'Ben Amor',
        email: 'slim.benamor@djerba.tn',
        country: 'Tunisie',
        memberNumber: 'ADP-2024-0482',
        tier: 'Membre Bienfaiteur',
        status: 'Actif',
        validUntil: '31/12/2026',
        directoryVisible: true,
        donationsTotal: 350,
        notificationsCount: 3
      },
      projects: [
        {
          id: 'prj-01',
          title: 'Restauration des Menzeh Traditionnels',
          category: 'Patrimoine',
          description: 'Préservation architecturale des habitations traditionnelles et huileries souterraines de Djerba.',
          collected: 18450,
          target: 25000,
          donorsCount: 142,
          daysLeft: 18,
          imageGradient: 'linear-gradient(135deg, #062D3C, #087E8B)',
          tags: ['UNESCO', 'Architecture', 'Culture']
        },
        {
          id: 'prj-02',
          title: 'Protection de la lagune des flamants roses',
          category: 'Écologie',
          description: 'Campagne de nettoyage, pose de nichoirs et sensibilisation à Ras Rmel pour sauvegarder la biodiversité.',
          collected: 8200,
          target: 10000,
          donorsCount: 96,
          daysLeft: 25,
          imageGradient: 'linear-gradient(135deg, #087E8B, #10A6A6)',
          tags: ['Faune', 'Écologie', 'Plages']
        },
        {
          id: 'prj-03',
          title: 'FabLab & Bourses Numériques pour les Jeunes',
          category: 'Éducation',
          description: 'Équipement d’un espace de formation technologique, codage et robotique pour les collégiens de Midoun.',
          collected: 14600,
          target: 15000,
          donorsCount: 118,
          daysLeft: 5,
          imageGradient: 'linear-gradient(135deg, #D86D4B, #E67D5B)',
          tags: ['Jeunesse', 'Tech', 'Éducation']
        },
        {
          id: 'prj-04',
          title: 'Valorisation des Potiers de Guellala',
          category: 'Économie',
          description: 'Aide à la transition vers des fours solaires et création d’un circuit touristique éco-responsable.',
          collected: 6300,
          target: 12000,
          donorsCount: 54,
          daysLeft: 42,
          imageGradient: 'linear-gradient(135deg, #062D3C, #D86D4B)',
          tags: ['Artisanat', 'Solaire', 'Économie']
        }
      ],
      news: [
        {
          id: 'news-01',
          title: 'Inscription de Djerba à l’UNESCO : les nouvelles retombées',
          date: '04 Sept 2026',
          category: 'Actualité',
          readTime: '3 min',
          summary: 'La reconnaissance mondiale accélère les projets de préservation et ouvre de nouveaux partenariats internationaux.',
          author: 'Comité Patrimoine'
        },
        {
          id: 'news-02',
          title: 'Bilan de la saison estivale 2026 : 40 tonnes de déchets collectés',
          date: '28 Août 2026',
          category: 'Écologie',
          readTime: '4 min',
          summary: 'Un engagement massif de la diaspora et des habitants pour un littoral plus propre.',
          author: 'Pôle Environnement'
        },
        {
          id: 'news-03',
          title: 'Lancement du Forum Diaspora & Entrepreneuriat',
          date: '15 Août 2026',
          category: 'Événement',
          readTime: '2 min',
          summary: 'Rendez-vous à Houmt Souk en décembre prochain pour connecter porteurs de projets et investisseurs.',
          author: 'Secrétariat ADP'
        }
      ],
      events: [
        {
          id: 'evt-01',
          title: 'Assemblée Générale Annuelle 2026',
          date: '12 Octobre 2026',
          day: '12',
          month: 'OCT',
          time: '14:30 - 18:00',
          location: 'Houmt Souk & Visioconférence',
          participants: 184,
          isRsvp: true
        },
        {
          id: 'evt-02',
          title: 'Rencontre Réseau Diaspora Paris',
          date: '24 Octobre 2026',
          day: '24',
          month: 'OCT',
          time: '19:00 - 22:00',
          location: 'Maison de la Tunisie, Paris',
          participants: 92,
          isRsvp: false
        },
        {
          id: 'evt-03',
          title: 'Atelier de plantation d’oliviers',
          date: '07 Novembre 2026',
          day: '07',
          month: 'NOV',
          time: '09:00 - 13:00',
          location: 'Ajim, Djerba',
          participants: 65,
          isRsvp: false
        }
      ],
      summit: {
        title: 'Djerba Diaspora Summit 2026',
        edition: '3ème Édition Internationale',
        dates: '18 - 20 Décembre 2026',
        location: 'Houmt Souk & Djerba Explore',
        attendeesCount: 420,
        isRegistered: true,
        tracks: [
          { id: 'trk-1', title: 'Tech, IA & Startups Diaspora', icon: 'memory', speaker: 'Tarek Bouzguenda', time: '18 Déc · 10:00' },
          { id: 'trk-2', title: 'Patrimoine & Post-UNESCO', icon: 'account_balance', speaker: 'Kamel Ghedamsi', time: '18 Déc · 14:30' },
          { id: 'trk-3', title: 'Transition Énergétique & Eau', icon: 'solar_power', speaker: 'Nadia Ben Youssef', time: '19 Déc · 09:30' },
          { id: 'trk-4', title: 'Entrepreneuriat Féminin & Artisanat', icon: 'handshake', speaker: 'Amel Haddad', time: '19 Déc · 15:00' }
        ],
        speakers: [
          { name: 'Dr. Myriam Trabelsi', role: 'Présidente ADP & Médecin', topic: 'Discours d\'ouverture : L\'île face aux défis du siècle' },
          { name: 'Tarek Bouzguenda', role: 'Managing Partner Diaspora Tech', topic: 'Fonds d\'amorçage 2M€ pour les projets insulaires' },
          { name: 'Kamel Ghedamsi', role: 'Architecte en chef UNESCO', topic: 'Sauvegarder l\'habitat vernaculaire de Djerba' },
          { name: 'Nadia Ben Youssef', role: 'VP Transition Écologique', topic: 'Djerba 100% solaire : feuille de route 2030' }
        ],
        livePoll: {
          question: 'Quel projet prioritaire doit recevoir la bourse spéciale du Sommet 2026 ?',
          options: [
            { id: 'opt-1', label: 'Usine de dessalement solaire villageoise', votes: 142 },
            { id: 'opt-2', label: 'Incubateur numérique jeunesse de Midoun', votes: 189 },
            { id: 'opt-3', label: 'Restauration des mosquées fortifiées', votes: 98 }
          ],
          userVoted: 'opt-2'
        }
      },
      preferences: {
        pushEnabled: true,
        eventsReminders: true,
        projectsUpdates: true,
        donationsReceipts: true,
        networkingAlerts: true
      },
      membersDirectory: [
        { id: 'm-01', name: 'Dr. Myriam Trabelsi', role: 'Médecin & Présidente ADP', location: 'Tunis / Djerba', skills: ['Santé', 'Gouvernance', 'Solidarité'], avatarText: 'MT' },
        { id: 'm-02', name: 'Kamel Ghedamsi', role: 'Architecte du Patrimoine', location: 'Houmt Souk', skills: ['UNESCO', 'Urbanisme', 'Conservation'], avatarText: 'KG' },
        { id: 'm-03', name: 'Nadia Ben Youssef', role: 'Ingénieure Énergie Solaire', location: 'Paris, France', skills: ['Photovoltaïque', 'R&D', 'Écologie'], avatarText: 'NY' },
        { id: 'm-04', name: 'Tarek Bouzguenda', role: 'Entrepreneur Tech & Diaspora', location: 'Lyon, France', skills: ['Venture Capital', 'IA', 'Fintech'], avatarText: 'TB' },
        { id: 'm-05', name: 'Amel Haddad', role: 'Enseignante & Éco-bénévole', location: 'Midoun', skills: ['Éducation', 'Jeunesse', 'Sensibilisation'], avatarText: 'AH' }
      ],
      notifications: [
        { id: 'notif-1', title: 'Don bien reçu !', message: 'Merci pour votre don de 50€ au projet Lagune.', time: 'Il y a 2h', unread: true },
        { id: 'notif-2', title: 'Votre e-Pass est actif', message: 'Votre carte membre 2026 a été renouvelée avec succès.', time: 'Hier', unread: true },
        { id: 'notif-3', title: 'Nouveau projet en ligne', message: 'Découvrez le FabLab pour les jeunes de Midoun.', time: 'Il y a 3 jours', unread: false }
      ]
    };
  }

  loadState() {
    try {
      const raw = localStorage.getItem(this.storageKey);
      if (raw) {
        return { ...this.getDefaultState(), ...JSON.parse(raw) };
      }
    } catch (e) {
      console.warn('Could not read localStorage:', e);
    }
    return this.getDefaultState();
  }

  saveState() {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(this.state));
    } catch (e) {
      console.warn('Could not save to localStorage:', e);
    }
    this.notify();
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  notify() {
    this.listeners.forEach(cb => cb(this.state));
  }

  // ── Actions ──
  login(email, password) {
    this.state.isAuthenticated = true;
    this.state.currentUser.email = email;
    this.saveState();
    return true;
  }

  register(userData) {
    this.state.isAuthenticated = true;
    this.state.currentUser = {
      ...this.state.currentUser,
      firstName: userData.firstName || 'Adhérent',
      lastName: userData.lastName || 'ADP',
      email: userData.email,
      country: userData.country || 'Tunisie',
      memberNumber: `ADP-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`
    };
    this.saveState();
    return true;
  }

  logout() {
    this.state.isAuthenticated = false;
    this.saveState();
  }

  toggleDirectoryVisible() {
    this.state.currentUser.directoryVisible = !this.state.currentUser.directoryVisible;
    this.saveState();
  }

  addDonation(projectId, amount) {
    const prj = this.state.projects.find(p => p.id === projectId);
    if (prj) {
      prj.collected += amount;
      prj.donorsCount += 1;
    }
    this.state.currentUser.donationsTotal += amount;
    this.state.notifications.unshift({
      id: 'notif-' + Date.now(),
      title: 'Don enregistré !',
      message: `Votre don de ${amount}€ a été pris en compte. Merci pour votre générosité !`,
      time: 'À l’instant',
      unread: true
    });
    this.saveState();
  }

  toggleEventRsvp(eventId) {
    const evt = this.state.events.find(e => e.id === eventId);
    if (evt) {
      evt.isRsvp = !evt.isRsvp;
      evt.participants += evt.isRsvp ? 1 : -1;
      this.saveState();
    }
  }

  markAllNotificationsRead() {
    this.state.notifications.forEach(n => n.unread = false);
    this.saveState();
  }

  toggleSummitRegistration() {
    this.state.summit.isRegistered = !this.state.summit.isRegistered;
    this.state.summit.attendeesCount += this.state.summit.isRegistered ? 1 : -1;
    this.saveState();
  }

  voteSummitPoll(optionId) {
    if (!this.state.summit.livePoll) return;
    const prev = this.state.summit.livePoll.userVoted;
    if (prev) {
      const prevOpt = this.state.summit.livePoll.options.find(o => o.id === prev);
      if (prevOpt) prevOpt.votes--;
    }
    const newOpt = this.state.summit.livePoll.options.find(o => o.id === optionId);
    if (newOpt) newOpt.votes++;
    this.state.summit.livePoll.userVoted = optionId;
    this.saveState();
  }

  sendConnectionRequest(recipientId, note) {
    const member = this.state.membersDirectory.find(m => m.id === recipientId);
    this.state.notifications.unshift({
      id: 'notif-' + Date.now(),
      title: 'Mise en relation envoyée',
      message: `Votre demande avec ${member ? member.name : 'le membre'} a été transmise en toute confidentialité.`,
      time: 'À l’instant',
      unread: true
    });
    this.saveState();
  }

  async syncFromBackend() {
    try {
      const [resProj, resNews, resEvents, resSummit] = await Promise.allSettled([
        fetch('/v1/projects').then(r => r.ok ? r.json() : null),
        fetch('/v1/news').then(r => r.ok ? r.json() : null),
        fetch('/v1/events').then(r => r.ok ? r.json() : null),
        fetch('/v1/summit').then(r => r.ok ? r.json() : null)
      ]);

      if (resProj.status === 'fulfilled' && Array.isArray(resProj.value) && resProj.value.length > 0) {
        // Enrich local projects with backend live figures
        resProj.value.forEach(bp => {
          const local = this.state.projects.find(p => p.id === bp.id);
          if (local) {
            local.collected = Math.round(bp.raisedCents / 100);
            local.target = Math.round(bp.targetCents / 100);
            local.location = bp.location || local.location;
          }
        });
        this.state.isBackendConnected = true;
      }

      if (resSummit.status === 'fulfilled' && resSummit.value) {
        this.state.summit = { ...this.state.summit, ...resSummit.value };
      }

      this.notify();
    } catch (e) {
      console.info('Backend sync offline or standalone mode:', e.message);
    }
  }

  exportUserData() {
    return JSON.stringify(this.state, null, 2);
  }
}

window.adpStore = new AdpStore();
window.adpStore.syncFromBackend();
