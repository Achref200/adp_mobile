/**
 * ADP Web Application — Studio Edition (2026/2027)
 * International Congress Standard · 100% Reliable Inline Vector SVGs
 */

document.addEventListener('DOMContentLoaded', () => {
  const appContainer = document.getElementById('app');
  const appFrame = document.getElementById('app-frame');
  const store = window.adpStore;
  const router = window.adpRouter;
  const icon = window.adpIcon;

  // ── Toast Notification ──
  function showToast(message, type = 'info') {
    let container = document.querySelector('.toast-container');
    if (!container) {
      container = document.createElement('div');
      container.className = 'toast-container';
      appFrame.appendChild(container);
    }
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    const icName = type === 'success' ? 'checkCircle' : 'compass';
    toast.innerHTML = `${icon(icName, 18, 'currentColor')} <span>${message}</span>`;
    container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(-8px)';
      setTimeout(() => toast.remove(), 240);
    }, 3000);
  }

  // ── Clock update in Status Bar ──
  function updateClock() {
    const timeEl = document.getElementById('status-time');
    if (timeEl) {
      const now = new Date();
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      timeEl.textContent = `${hours}:${minutes}`;
    }
  }
  setInterval(updateClock, 1000);

  // ── Top Studio Toolbar ──
  function renderToolbar() {
    let toolbar = document.querySelector('.device-toolbar');
    if (!toolbar) {
      toolbar = document.createElement('div');
      toolbar.className = 'device-toolbar';
      appFrame.parentNode.insertBefore(toolbar, appFrame);
    }
    toolbar.innerHTML = `
      <div style="display: flex; align-items: center; gap: 7px;">
        ${icon('compass', 16, 'var(--sand-gold)')}
        <span style="font-weight: 700; font-size: 12px; letter-spacing: 0.3px;">ADP CONGRÈS 2026</span>
      </div>
      <select id="screen-selector">
        <option value="/splash">1. Splash Screen</option>
        <option value="/onboarding">2. Onboarding Interactif</option>
        <option value="/auth/login">3. Connexion</option>
        <option value="/auth/register">4. Inscription</option>
        <option value="/home">5. Accueil Dashboard</option>
        <option value="/projects">6. Projets Citoyens</option>
        <option value="/summit">7. Sommet Diaspora 2026</option>
        <option value="/epass">8. e-Pass Membre</option>
        <option value="/donate">9. Faire un Don</option>
        <option value="/membership/start">10. Adhésion & Cotisation</option>
        <option value="/networking">11. Annuaire Réseau</option>
        <option value="/events">12. Agenda & Rencontres</option>
        <option value="/news">13. Actualités de l'île</option>
        <option value="/notifications">14. Notifications</option>
        <option value="/profile">15. Mon Profil & RGPD</option>
        <option value="/payment-return">16. Confirmation Paiement</option>
      </select>
      <button id="toggle-frame-btn" title="Changer format">
        ${icon('devices', 15, '#fff')}
      </button>
    `;

    const select = toolbar.querySelector('#screen-selector');
    select.addEventListener('change', (e) => router.navigate(e.target.value));

    const toggleBtn = toolbar.querySelector('#toggle-frame-btn');
    toggleBtn.addEventListener('click', () => {
      if (appFrame.style.width === '100%') {
        appFrame.style.width = '390px';
        appFrame.style.borderRadius = '46px';
        toggleBtn.innerHTML = icon('devices', 15, '#fff');
        showToast('Format Smartphone (390px)', 'info');
      } else {
        appFrame.style.width = '100%';
        appFrame.style.maxWidth = '760px';
        appFrame.style.borderRadius = '28px';
        toggleBtn.innerHTML = icon('devices', 15, '#fff');
        showToast('Format Écran Large', 'info');
      }
    });
  }

  // ── Bottom Navigation Component (Pure Vector SVGs) ──
  function getBottomNavHtml(currentRoute) {
    return `
      <nav class="bottom-nav">
        <a href="#/home" class="nav-item ${currentRoute === '/home' ? 'active' : ''}">
          ${icon('home', 22, currentRoute === '/home' ? 'var(--ink)' : 'var(--muted)')}
          <span class="label">Accueil</span>
        </a>
        <a href="#/projects" class="nav-item ${currentRoute === '/projects' ? 'active' : ''}">
          ${icon('plant', 22, currentRoute === '/projects' ? 'var(--ink)' : 'var(--muted)')}
          <span class="label">Projets</span>
        </a>
        <a href="#/epass" class="nav-item ${currentRoute === '/epass' ? 'active' : ''}">
          ${icon('idCard', 22, currentRoute === '/epass' ? 'var(--ink)' : 'var(--muted)')}
          <span class="label">e-Pass</span>
        </a>
        <a href="#/profile" class="nav-item ${currentRoute === '/profile' ? 'active' : ''}">
          ${icon('user', 22, currentRoute === '/profile' ? 'var(--ink)' : 'var(--muted)')}
          <span class="label">Profil</span>
        </a>
      </nav>
    `;
  }

  // ── Status Bar Component (Vector SVGs) ──
  function getStatusBarHtml(isDark = false) {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const clr = isDark ? '#fff' : 'var(--ink)';
    return `
      <div class="status-bar ${isDark ? 'dark' : ''}">
        <span id="status-time">${hours}:${minutes}</span>
        <div class="notch-island">
          <div class="notch-cam"></div>
          <div class="notch-sensor"></div>
        </div>
        <div class="status-bar-icons">
          ${icon('signal', 13, clr)}
          ${icon('wifi', 13, clr)}
          ${icon('battery', 13, clr)}
        </div>
      </div>
    `;
  }

  // ─────────────────────────────────────────────
  // 1. SPLASH SCREEN (Clean & Typographic)
  // ─────────────────────────────────────────────
  router.register('/splash', () => {
    appContainer.innerHTML = `
      <div class="screen splash-screen" style="background: #FBF9F5; color: var(--ink); padding: 24px 28px; justify-content: space-between; text-align: center;">
        ${getStatusBarHtml(false)}
        
        <!-- Top Cultural Greeting Badge -->
        <div style="display: flex; justify-content: center; margin-top: 18px;">
          <div style="background: #F1EDE4; border: 1px solid #E2DDD3; border-radius: 30px; padding: 6px 16px; display: inline-flex; align-items: center; gap: 8px;">
            <span style="font-size: 13.5px; font-weight: 700; color: var(--terracotta);">مرحباً بك</span>
            <span style="font-size: 10px; font-weight: 800; letter-spacing: 1.2px; color: var(--ink); opacity: 0.85;">· BIENVENUE</span>
          </div>
        </div>

        <!-- Center Architectural Emblem & Narrative -->
        <div style="display: flex; flex-direction: column; align-items: center; margin: auto 0;">
          <!-- Custom SVG Architectural Djerba Vault & Sun -->
          <div style="width: 124px; height: 124px; border-radius: 50%; background: #F7EFE4; border: 1.5px solid #EADBCE; display: flex; align-items: center; justify-content: center; margin-bottom: 26px; box-shadow: 0 10px 24px rgba(14,33,41,0.06);">
            <svg width="84" height="84" viewBox="0 0 100 100" fill="none">
              <!-- Traditional Archway -->
              <path d="M 28 82 L 28 46 A 22 22 0 0 1 72 46 L 72 82 Z" fill="#0E2129"/>
              <!-- Rising Golden Sun -->
              <circle cx="50" cy="52" r="14" fill="#D5AB72"/>
              <!-- Sea Water Line -->
              <path d="M 28 64 L 72 64 L 72 82 L 28 82 Z" fill="#0D6274"/>
              <!-- Clay Finial Pot on Top -->
              <circle cx="50" cy="20" r="4.5" fill="#D46238"/>
            </svg>
          </div>

          <div style="font-size: 12px; font-weight: 700; letter-spacing: 4px; color: var(--muted); margin-bottom: 4px;">ASSOCIATION</div>
          <h1 style="font-family: 'Barlow Condensed', sans-serif; font-size: 34px; font-weight: 900; letter-spacing: 1px; line-height: 1.05; color: var(--ink); margin-bottom: 12px;">
            DJERBA PROJECT
          </h1>
          <p style="font-size: 13.5px; font-style: italic; color: var(--muted); line-height: 1.5; max-width: 270px; margin: 0 auto;">
            « L'île que nous chérissons, l'avenir que nous bâtissons ensemble. »
          </p>
        </div>

        <!-- Bottom Roots & Action -->
        <div style="display: flex; flex-direction: column; align-items: center; gap: 14px; width: 100%; margin-bottom: 8px;">
          <div style="width: 32px; height: 2px; background: var(--sand-gold); border-radius: 1px;"></div>
          <div style="font-size: 9.5px; font-weight: 800; letter-spacing: 1.5px; color: var(--muted);">
            INITIATIVE CITOYENNE DE LA DIASPORA
          </div>
          <div style="display: flex; gap: 10px; width: 100%;">
            <button class="btn btn-primary btn-block btn-sm" id="start-onboarding-btn">
              Découvrir ${icon('arrowRight', 14, '#fff')}
            </button>
            <button class="btn btn-secondary btn-block btn-sm" onclick="adpRouter.navigate('/home')">
              Accès Direct
            </button>
          </div>
        </div>

        <div class="home-indicator"></div>
      </div>
    `;

    document.getElementById('start-onboarding-btn').addEventListener('click', () => {
      router.navigate('/onboarding');
    });

    setTimeout(() => {
      if (window.location.hash.includes('/splash')) {
        router.navigate('/onboarding');
      }
    }, 4000);
  });

  // ─────────────────────────────────────────────
  // 2. ONBOARDING (Interactive 4-Step Grinta Style)
  // ─────────────────────────────────────────────
  let onboardStep = 1;
  let userChoices = {
    connection: 'diaspora',
    priorities: ['Patrimoine UNESCO & Menzeh', 'Littoral & Zéro Déchet'],
    path: 'member'
  };

  router.register('/onboarding', () => {
    function renderStep() {
      if (onboardStep === 1) {
        appContainer.innerHTML = `
          <div class="screen onboarding-flow">
            ${getStatusBarHtml(false)}
            <div class="onboarding-top-bar">
              <button class="icon-btn" onclick="adpRouter.navigate('/splash')">${icon('arrowLeft', 16)}</button>
              <div class="onboarding-step-indicator">
                <div class="step-bar active"></div>
                <div class="step-bar"></div>
                <div class="step-bar"></div>
                <div class="step-bar"></div>
              </div>
              <a href="#/home" style="font-size: 13px; font-weight: 700; color: var(--muted);">Passer</a>
            </div>

            <div class="onboarding-step-content">
              <span class="text-label-xs" style="color: var(--terracotta); margin-bottom: 6px;">Étape 1 sur 4 · Origine</span>
              <h2 class="onboarding-headline">Quel est votre lien avec Djerba ?</h2>
              <p class="onboarding-sub">Pour connecter votre profil à la communauté qui vous correspond.</p>

              <div style="display: flex; flex-direction: column; gap: 10px;">
                <div class="choice-card ${userChoices.connection === 'diaspora' ? 'selected' : ''}" onclick="selectConnection('diaspora')">
                  <div style="display: flex; align-items: center; gap: 12px;">
                    ${icon('globe', 22, 'var(--ocean)')}
                    <div>
                      <div style="font-size: 14.5px; font-weight: 700;">Diaspora djerbienne</div>
                      <div style="font-size: 12px; color: var(--muted);">En France, Europe ou ailleurs dans le monde</div>
                    </div>
                  </div>
                  <div class="choice-radio">${icon('check', 11, userChoices.connection === 'diaspora' ? '#fff' : 'transparent')}</div>
                </div>

                <div class="choice-card ${userChoices.connection === 'resident' ? 'selected' : ''}" onclick="selectConnection('resident')">
                  <div style="display: flex; align-items: center; gap: 12px;">
                    ${icon('home', 22, 'var(--terracotta)')}
                    <div>
                      <div style="font-size: 14.5px; font-weight: 700;">Résident ou Originaire de l'île</div>
                      <div style="font-size: 12px; color: var(--muted);">Houmt Souk, Midoun, Ajim, Guellala...</div>
                    </div>
                  </div>
                  <div class="choice-radio">${icon('check', 11, userChoices.connection === 'resident' ? '#fff' : 'transparent')}</div>
                </div>

                <div class="choice-card ${userChoices.connection === 'friend' ? 'selected' : ''}" onclick="selectConnection('friend')">
                  <div style="display: flex; align-items: center; gap: 12px;">
                    ${icon('heart', 22, '#10B981')}
                    <div>
                      <div style="font-size: 14.5px; font-weight: 700;">Ami & Amoureux de Djerba</div>
                      <div style="font-size: 12px; color: var(--muted);">Attaché au patrimoine et aux habitants</div>
                    </div>
                  </div>
                  <div class="choice-radio">${icon('check', 11, userChoices.connection === 'friend' ? '#fff' : 'transparent')}</div>
                </div>
              </div>
            </div>

            <button class="btn btn-primary btn-block" onclick="nextOnboardingStep()">
              Continuer ${icon('arrowRight', 16, '#fff')}
            </button>
            <div class="home-indicator"></div>
          </div>
        `;
      } else if (onboardStep === 2) {
        const allCauses = [
          'Patrimoine UNESCO & Menzeh',
          'Littoral & Zéro Déchet',
          'FabLab & Jeunesse Midoun',
          'Fours Solaires Guellala',
          'Santé & Hôpital Insulaire',
          'Dessalement Solaire'
        ];

        appContainer.innerHTML = `
          <div class="screen onboarding-flow">
            ${getStatusBarHtml(false)}
            <div class="onboarding-top-bar">
              <button class="icon-btn" onclick="prevOnboardingStep()">${icon('arrowLeft', 16)}</button>
              <div class="onboarding-step-indicator">
                <div class="step-bar active"></div>
                <div class="step-bar active"></div>
                <div class="step-bar"></div>
                <div class="step-bar"></div>
              </div>
              <a href="#/home" style="font-size: 13px; font-weight: 700; color: var(--muted);">Passer</a>
            </div>

            <div class="onboarding-step-content">
              <span class="text-label-xs" style="color: var(--terracotta); margin-bottom: 6px;">Étape 2 sur 4 · Priorités</span>
              <h2 class="onboarding-headline">Quelles causes vous tiennent à cœur ?</h2>
              <p class="onboarding-sub">Sélectionnez les projets que vous souhaitez voir progresser.</p>

              <div class="chips-grid">
                ${allCauses.map(cause => {
                  const isSelected = userChoices.priorities.includes(cause);
                  return `
                    <div class="selectable-chip ${isSelected ? 'active' : ''}" onclick="togglePriority('${cause}')">
                      ${icon(isSelected ? 'check' : 'plant', 13, isSelected ? '#fff' : 'var(--ocean)')}
                      <span>${cause}</span>
                    </div>
                  `;
                }).join('')}
              </div>

              <div class="card card-soft" style="margin-top: 24px; padding: 14px 16px;">
                <div style="font-size: 12.5px; color: var(--muted); display: flex; align-items: center; gap: 8px;">
                  ${icon('checkCircle', 18, 'var(--ocean)')}
                  <span>100% des dons ADP vont directement aux projets validés par l'AG.</span>
                </div>
              </div>
            </div>

            <button class="btn btn-primary btn-block" onclick="nextOnboardingStep()">
              Valider mes priorités (${userChoices.priorities.length}) ${icon('arrowRight', 16, '#fff')}
            </button>
            <div class="home-indicator"></div>
          </div>
        `;
      } else if (onboardStep === 3) {
        appContainer.innerHTML = `
          <div class="screen onboarding-flow">
            ${getStatusBarHtml(false)}
            <div class="onboarding-top-bar">
              <button class="icon-btn" onclick="prevOnboardingStep()">${icon('arrowLeft', 16)}</button>
              <div class="onboarding-step-indicator">
                <div class="step-bar active"></div>
                <div class="step-bar active"></div>
                <div class="step-bar active"></div>
                <div class="step-bar"></div>
              </div>
              <a href="#/home" style="font-size: 13px; font-weight: 700; color: var(--muted);">Passer</a>
            </div>

            <div class="onboarding-step-content">
              <span class="text-label-xs" style="color: var(--terracotta); margin-bottom: 6px;">Étape 3 sur 4 · Engagement</span>
              <h2 class="onboarding-headline">Comment souhaitez-vous agir ?</h2>
              <p class="onboarding-sub">Deux statuts transparents définis par la charte ADP.</p>

              <div style="display: flex; flex-direction: column; gap: 12px;">
                <div class="choice-card ${userChoices.path === 'member' ? 'selected' : ''}" onclick="selectPath('member')">
                  <div>
                    <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 4px;">
                      <span class="badge badge-ocean">OFFICIEL</span>
                      <span style="font-size: 11px; color: var(--muted); font-weight: 700;">Recommandé</span>
                    </div>
                    <div style="font-size: 15px; font-weight: 800;">Adhérent Actif ADP</div>
                    <div style="font-size: 12px; color: var(--muted); margin-top: 3px;">
                      Droit de vote à l'AG, carte e-Pass digitale, accès aux commissions de projets.
                    </div>
                  </div>
                  <div class="choice-radio">${icon('check', 11, userChoices.path === 'member' ? '#fff' : 'transparent')}</div>
                </div>

                <div class="choice-card ${userChoices.path === 'sympathisant' ? 'selected' : ''}" onclick="selectPath('sympathisant')">
                  <div>
                    <span class="badge badge-neutral" style="margin-bottom: 4px;">ACCÈS LIBRE</span>
                    <div style="font-size: 15px; font-weight: 800;">Sympathisant</div>
                    <div style="font-size: 12px; color: var(--muted); margin-top: 3px;">
                      Suivi transparent des actualités, dons libres, invitations aux événements ouverts.
                    </div>
                  </div>
                  <div class="choice-radio">${icon('check', 11, userChoices.path === 'sympathisant' ? '#fff' : 'transparent')}</div>
                </div>
              </div>
            </div>

            <button class="btn btn-primary btn-block" onclick="nextOnboardingStep()">
              Générer mon profil ${icon('arrowRight', 16, '#fff')}
            </button>
            <div class="home-indicator"></div>
          </div>
        `;
      } else if (onboardStep === 4) {
        const user = store.state.currentUser;
        appContainer.innerHTML = `
          <div class="screen onboarding-flow">
            ${getStatusBarHtml(false)}
            <div class="onboarding-top-bar">
              <button class="icon-btn" onclick="prevOnboardingStep()">${icon('arrowLeft', 16)}</button>
              <div class="onboarding-step-indicator">
                <div class="step-bar active"></div>
                <div class="step-bar active"></div>
                <div class="step-bar active"></div>
                <div class="step-bar active"></div>
              </div>
              <div style="width: 38px;"></div>
            </div>

            <div class="onboarding-step-content" style="align-items: center; text-align: center;">
              <span class="text-label-xs" style="color: var(--success); margin-bottom: 6px;">
                ${icon('checkCircle', 14, 'var(--success)')} Prêt pour Djerba
              </span>
              <h2 class="onboarding-headline" style="font-size: 30px;">Votre e-Pass digital est prêt</h2>
              <p class="onboarding-sub" style="margin-bottom: 24px;">Votre identifiant officiel au sein de la communauté.</p>

              <div class="pass-card-wrap">
                <div class="digital-pass">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                      ${icon('compass', 22, 'var(--sand-gold)')}
                      <span style="font-family: 'Barlow Condensed'; font-size: 18px; font-weight: 800; letter-spacing: 0.5px;">ADP DJERBA</span>
                    </div>
                    <span class="badge badge-neutral" style="background: rgba(255,255,255,0.14); color: #fff;">2026</span>
                  </div>

                  <div style="text-align: left; margin: 16px 0;">
                    <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 1px; opacity: 0.7;">Titulaire</div>
                    <div style="font-size: 20px; font-weight: 800; letter-spacing: 0.3px;">${user.firstName} ${user.lastName}</div>
                    <div style="font-size: 12px; font-family: monospace; color: var(--sand-gold); margin-top: 2px;">${user.memberNumber}</div>
                  </div>

                  <div style="display: flex; justify-content: space-between; align-items: flex-end; border-top: 1px solid rgba(255,255,255,0.12); padding-top: 10px;">
                    <div style="text-align: left;">
                      <div style="font-size: 9px; opacity: 0.6; text-transform: uppercase;">Lien</div>
                      <div style="font-size: 12px; font-weight: 700;">${userChoices.connection === 'diaspora' ? 'Diaspora Europe' : 'Résident Djerba'}</div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 4px; font-size: 11px; color: #6ee7b7; font-weight: 700;">
                      ${icon('checkCircle', 12, '#6ee7b7')} ACTIF
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div style="display: flex; flex-direction: column; gap: 10px;">
              <button class="btn btn-primary btn-block" onclick="adpRouter.navigate('/home')">
                Entrer dans l'application ${icon('arrowRight', 16, '#fff')}
              </button>
              <button class="btn btn-secondary btn-block" onclick="adpRouter.navigate('/auth/login')">
                Se connecter avec un autre compte
              </button>
            </div>
            <div class="home-indicator"></div>
          </div>
        `;
      }
    }

    window.selectConnection = (c) => {
      userChoices.connection = c;
      renderStep();
    };

    window.togglePriority = (p) => {
      if (userChoices.priorities.includes(p)) {
        userChoices.priorities = userChoices.priorities.filter(x => x !== p);
      } else {
        userChoices.priorities.push(p);
      }
      renderStep();
    };

    window.selectPath = (p) => {
      userChoices.path = p;
      renderStep();
    };

    window.nextOnboardingStep = () => {
      if (onboardStep < 4) {
        onboardStep++;
        renderStep();
      } else {
        router.navigate('/home');
      }
    };

    window.prevOnboardingStep = () => {
      if (onboardStep > 1) {
        onboardStep--;
        renderStep();
      } else {
        router.navigate('/splash');
      }
    };

    renderStep();
  });

  // ─────────────────────────────────────────────
  // 3. AUTHENTICATION (Login & Register)
  // ─────────────────────────────────────────────
  router.register('/auth/login', () => {
    appContainer.innerHTML = `
      <div class="screen" style="padding: 10px 20px 32px 20px; justify-content: space-between;">
        ${getStatusBarHtml(false)}
        <div class="app-bar" style="padding: 0 0 12px 0;">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <span class="badge badge-neutral">ESPACE MEMBRE</span>
        </div>

        <div>
          <h1 class="onboarding-headline">Bon retour parmi nous</h1>
          <p class="onboarding-sub">Connectez-vous pour retrouver votre e-Pass et vos contributions.</p>

          <form id="login-form">
            <div class="form-group">
              <label class="form-label">Email</label>
              <div class="input-wrapper">
                <span class="input-icon">${icon('mail', 18, 'var(--muted)')}</span>
                <input type="email" class="form-control" id="login-email" value="slim.benamor@djerba.tn" required placeholder="nom@exemple.com">
              </div>
            </div>

            <div class="form-group">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <label class="form-label">Mot de passe</label>
                <a href="#/auth/forgot-password" style="font-size: 11.5px; font-weight: 700; color: var(--muted);">Oublié ?</a>
              </div>
              <div class="input-wrapper">
                <span class="input-icon">${icon('lock', 18, 'var(--muted)')}</span>
                <input type="password" class="form-control" id="login-password" value="Password123!" required placeholder="••••••••">
              </div>
            </div>

            <button type="submit" class="btn btn-primary btn-block" style="margin-top: 14px;">
              Se connecter ${icon('arrowRight', 16, '#fff')}
            </button>
          </form>

          <div style="text-align: center; margin: 20px 0 10px 0;">
            <a href="#/auth/register" style="font-size: 13px; font-weight: 700; color: var(--ink);">Nouveau sur ADP ? <span style="color: var(--terracotta);">Créer un compte</span></a>
          </div>
        </div>

        <button class="btn btn-outline btn-block btn-sm" onclick="adpRouter.navigate('/home')">
          Continuer en invité
        </button>
        <div class="home-indicator"></div>
      </div>
    `;

    document.getElementById('login-form').addEventListener('submit', (e) => {
      e.preventDefault();
      const email = document.getElementById('login-email').value;
      const pass = document.getElementById('login-password').value;
      store.login(email, pass);
      showToast('Session restaurée avec succès', 'success');
      router.navigate('/home');
    });
  });

  router.register('/auth/register', () => {
    appContainer.innerHTML = `
      <div class="screen" style="padding: 10px 20px 32px 20px; overflow-y: auto;">
        ${getStatusBarHtml(false)}
        <div class="app-bar" style="padding: 0 0 12px 0;">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <span class="badge badge-neutral">ADHÉSION</span>
        </div>

        <h1 class="onboarding-headline">Rejoindre l'ADP</h1>
        <p class="onboarding-sub">Faites entendre votre voix pour le développement de l'île.</p>

        <form id="reg-form">
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
            <div class="form-group">
              <label class="form-label">Prénom</label>
              <input type="text" class="form-control no-icon" id="reg-firstname" required placeholder="Slim">
            </div>
            <div class="form-group">
              <label class="form-label">Nom</label>
              <input type="text" class="form-control no-icon" id="reg-lastname" required placeholder="Ben Amor">
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Email</label>
            <div class="input-wrapper">
              <span class="input-icon">${icon('mail', 18, 'var(--muted)')}</span>
              <input type="email" class="form-control" id="reg-email" required placeholder="slim@exemple.com">
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Résidence</label>
            <div class="input-wrapper">
              <span class="input-icon">${icon('globe', 18, 'var(--muted)')}</span>
              <input type="text" class="form-control" id="reg-country" value="Tunisie" required placeholder="Tunisie, France...">
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Lien avec Djerba</label>
            <div class="input-wrapper">
              <span class="input-icon">${icon('mapPin', 18, 'var(--muted)')}</span>
              <input type="text" class="form-control" id="reg-connection" placeholder="Origine familiale, habitant, projet...">
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Mot de passe</label>
            <div class="input-wrapper">
              <span class="input-icon">${icon('lock', 18, 'var(--muted)')}</span>
              <input type="password" class="form-control" id="reg-password" required minlength="8" placeholder="Au moins 8 caractères">
            </div>
          </div>

          <button type="submit" class="btn btn-terracotta btn-block" style="margin-top: 10px;">
            Finaliser mon inscription ${icon('check', 16, '#fff')}
          </button>
        </form>

        <div style="text-align: center; margin-top: 18px;">
          <a href="#/auth/login" style="font-size: 13px; font-weight: 700; color: var(--muted);">Déjà inscrit ? <span style="color: var(--ink);">Se connecter</span></a>
        </div>
        <div class="home-indicator"></div>
      </div>
    `;

    document.getElementById('reg-form').addEventListener('submit', (e) => {
      e.preventDefault();
      const firstName = document.getElementById('reg-firstname').value;
      const lastName = document.getElementById('reg-lastname').value;
      const email = document.getElementById('reg-email').value;
      const country = document.getElementById('reg-country').value;
      store.register({ firstName, lastName, email, country });
      showToast('Compte créé avec succès !', 'success');
      router.navigate('/home');
    });
  });

  router.register('/auth/forgot-password', () => {
    appContainer.innerHTML = `
      <div class="screen" style="padding: 10px 20px 32px 20px; justify-content: space-between;">
        ${getStatusBarHtml(false)}
        <div class="app-bar" style="padding: 0 0 12px 0;">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
        </div>

        <div>
          <h1 class="onboarding-headline">Réinitialisation</h1>
          <p class="onboarding-sub">Indiquez votre email pour recevoir les instructions.</p>
          <form id="forgot-form">
            <div class="form-group">
              <label class="form-label">Email</label>
              <div class="input-wrapper">
                <span class="input-icon">${icon('mail', 18, 'var(--muted)')}</span>
                <input type="email" class="form-control" required placeholder="nom@exemple.com">
              </div>
            </div>
            <button type="submit" class="btn btn-primary btn-block" style="margin-top: 12px;">
              Envoyer le lien ${icon('arrowRight', 16, '#fff')}
            </button>
          </form>
        </div>
        <div></div>
        <div class="home-indicator"></div>
      </div>
    `;
    document.getElementById('forgot-form').addEventListener('submit', (e) => {
      e.preventDefault();
      showToast('Lien envoyé par email', 'success');
      router.navigate('/auth/login');
    });
  });

  // ─────────────────────────────────────────────
  // 4. HOME DASHBOARD (Clean Editorial Experience)
  // ─────────────────────────────────────────────
  router.register('/home', () => {
    const user = store.state.currentUser;
    const topProject = store.state.projects[0];

    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        
        <div class="screen-body" style="padding-top: 6px;">
          <!-- Human Header -->
          <div class="home-header">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div class="home-user-avatar">
                ${user.firstName[0]}${user.lastName[0]}
              </div>
              <div>
                <div style="display: flex; align-items: center; gap: 6px;">
                  <span style="font-size: 16px; font-weight: 800;">${user.firstName} ${user.lastName}</span>
                  ${icon('checkCircle', 15, 'var(--ocean)')}
                </div>
                <div style="font-size: 11.5px; color: var(--muted); font-weight: 600;">${user.tier} · ${user.country}</div>
              </div>
            </div>

            <div style="display: flex; gap: 8px;">
              <button class="icon-btn" onclick="adpRouter.navigate('/notifications')">
                ${icon('bell', 18)}
              </button>
              <button class="icon-btn" onclick="adpRouter.navigate('/epass')" title="e-Pass">
                ${icon('qrCode', 18)}
              </button>
            </div>
          </div>

          <!-- 3-Column Impact Stats -->
          <div class="stats-grid-card">
            <div class="stat-col">
              <div class="stat-number">${user.donationsTotal} €</div>
              <div class="stat-label">Contributions</div>
            </div>
            <div class="stat-col">
              <div class="stat-number">${store.state.projects.length}</div>
              <div class="stat-label">Projets actifs</div>
            </div>
            <div class="stat-col">
              <div class="stat-number" style="color: var(--success);">2026</div>
              <div class="stat-label">Statut actif</div>
            </div>
          </div>

          <!-- 4 Direct Action Buttons -->
          <div class="action-grid">
            <button class="action-card-btn" onclick="adpRouter.navigate('/donate')">
              <div class="action-card-icon">
                ${icon('heart', 22, 'var(--terracotta)')}
              </div>
              <span class="action-card-label">Faire un don</span>
            </button>

            <button class="action-card-btn" onclick="adpRouter.navigate('/epass')">
              <div class="action-card-icon">
                ${icon('idCard', 22, 'var(--ocean)')}
              </div>
              <span class="action-card-label">Mon e-Pass</span>
            </button>

            <button class="action-card-btn" onclick="adpRouter.navigate('/networking')">
              <div class="action-card-icon">
                ${icon('users', 22, '#0E7490')}
              </div>
              <span class="action-card-label">Réseau</span>
            </button>

            <button class="action-card-btn" onclick="adpRouter.navigate('/summit')">
              <div class="action-card-icon">
                ${icon('globe', 22, 'var(--sand-gold)')}
              </div>
              <span class="action-card-label">Sommet</span>
            </button>
          </div>

          <!-- Summit Highlight Card -->
          <div class="card" style="margin-bottom: 20px; border-left: 3.5px solid var(--sand-gold); cursor: pointer;" onclick="adpRouter.navigate('/summit')">
            <div style="display: flex; justify-content: space-between; align-items: flex-start;">
              <div>
                <span class="badge badge-neutral" style="font-size: 10px; margin-bottom: 4px;">ÉVÉNEMENT 2026</span>
                <h3 style="font-size: 15.5px; font-weight: 800;">Djerba Diaspora Summit</h3>
                <p style="font-size: 12px; color: var(--muted); margin-top: 2px;">18-20 Décembre · Houmt Souk · 420 participants</p>
              </div>
              ${icon('arrowRight', 16, 'var(--ink)')}
            </div>
          </div>

          <!-- Featured Project Story Card -->
          <div class="section-bar">
            <span class="section-heading">Projet Prioritaire</span>
            <span class="section-link" onclick="adpRouter.navigate('/projects')">Tous les projets</span>
          </div>

          <div class="story-project-card">
            <div class="story-project-header" style="background: linear-gradient(135deg, #0A1C24 0%, #153A47 100%);">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span class="badge" style="background: rgba(255,255,255,0.18); color: #fff;">${topProject.category}</span>
                <span style="font-size: 11px; opacity: 0.8; font-weight: 700;">J-${topProject.daysLeft}</span>
              </div>
              <div style="font-size: 12px; color: var(--sand-gold); font-weight: 600;">Action terrain en cours</div>
            </div>

            <div class="story-project-body">
              <h3 style="font-size: 16px; font-weight: 800; margin-bottom: 6px;">${topProject.title}</h3>
              <p style="font-size: 12.5px; color: var(--muted); line-height: 1.45; margin-bottom: 14px;">${topProject.description}</p>
              
              <div class="progress-container" style="margin-bottom: 8px;">
                <div class="progress-fill" style="width: ${(topProject.collected / topProject.target * 100).toFixed(0)}%;"></div>
              </div>
              <div style="display: flex; justify-content: space-between; font-size: 12px; font-weight: 700; margin-bottom: 14px;">
                <span>${topProject.collected.toLocaleString()} € récoltés</span>
                <span style="color: var(--ocean);">${(topProject.collected / topProject.target * 100).toFixed(0)}% de ${topProject.target.toLocaleString()} €</span>
              </div>

              <div style="display: flex; gap: 8px;">
                <button class="btn btn-primary btn-sm" style="flex: 1;" onclick="adpRouter.navigate('/donate', { projectId: '${topProject.id}' })">
                  ${icon('heart', 16, '#fff')} Contribuer
                </button>
              </div>
            </div>
          </div>

          <!-- Latest Dispatches -->
          <div class="section-bar" style="margin-top: 18px;">
            <span class="section-heading">Nouvelles de Djerba</span>
            <span class="section-link" onclick="adpRouter.navigate('/news')">Archives</span>
          </div>

          ${store.state.news.slice(0, 2).map(n => `
            <div class="card" style="padding: 14px; margin-bottom: 10px; cursor: pointer;" onclick="adpRouter.navigate('/news')">
              <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                <span class="badge badge-ocean" style="font-size: 10px;">${n.category}</span>
                <span style="font-size: 11px; color: var(--muted);">${n.date}</span>
              </div>
              <h4 style="font-size: 14px; font-weight: 800; margin-bottom: 4px;">${n.title}</h4>
              <p style="font-size: 12px; color: var(--muted);">${n.summary}</p>
            </div>
          `).join('')}
        </div>

        ${getBottomNavHtml('/home')}
        <div class="home-indicator"></div>
      </div>
    `;
  });

  // ─────────────────────────────────────────────
  // 5. PROJECTS CATALOG
  // ─────────────────────────────────────────────
  let currentProjectCategory = 'Tous';
  router.register('/projects', () => {
    const cats = ['Tous', 'Patrimoine', 'Écologie', 'Éducation', 'Économie'];
    const filtered = currentProjectCategory === 'Tous'
      ? store.state.projects
      : store.state.projects.filter(p => p.category === currentProjectCategory);

    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <h1 class="app-bar-title">Projets de l'île</h1>
          <button class="icon-btn" onclick="adpRouter.navigate('/donate')">${icon('heart', 18, 'var(--terracotta)')}</button>
        </div>

        <div class="screen-body">
          <div class="pills-scroll">
            ${cats.map(c => `
              <div class="pill-item ${c === currentProjectCategory ? 'active' : ''}" onclick="filterCat('${c}')">${c}</div>
            `).join('')}
          </div>

          <div style="font-size: 12px; color: var(--muted); font-weight: 700; margin-bottom: 14px;">
            ${filtered.length} initiatives en cours de soutien
          </div>

          ${filtered.map(p => {
            const pct = Math.min(100, (p.collected / p.target * 100)).toFixed(0);
            return `
              <div class="story-project-card">
                <div class="story-project-header" style="background: linear-gradient(135deg, #0E2129 0%, #173744 100%);">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span class="badge" style="background: rgba(255,255,255,0.16); color: #fff;">${p.category}</span>
                    <span style="font-size: 11px; opacity: 0.8; font-weight: 700;">J-${p.daysLeft}</span>
                  </div>
                  <div style="font-size: 12px; color: var(--sand-gold); font-weight: 600;">Djerba Project · 2026</div>
                </div>
                <div class="story-project-body">
                  <h3 style="font-size: 15.5px; font-weight: 800; margin-bottom: 6px;">${p.title}</h3>
                  <p style="font-size: 12.5px; color: var(--muted); line-height: 1.45; margin-bottom: 12px;">${p.description}</p>
                  
                  <div class="progress-container" style="margin-bottom: 6px;">
                    <div class="progress-fill" style="width: ${pct}%;"></div>
                  </div>
                  <div style="display: flex; justify-content: space-between; font-size: 11.5px; font-weight: 700; margin-bottom: 12px;">
                    <span>${p.collected.toLocaleString()} €</span>
                    <span style="color: var(--ocean);">${pct}% de ${p.target.toLocaleString()} €</span>
                  </div>

                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 11.5px; color: var(--muted);">${icon('users', 14, 'var(--muted)')} ${p.donorsCount} donateurs</span>
                    <button class="btn btn-primary btn-sm" onclick="adpRouter.navigate('/donate', { projectId: '${p.id}' })">
                      Soutenir
                    </button>
                  </div>
                </div>
              </div>
            `;
          }).join('')}
        </div>
        ${getBottomNavHtml('/projects')}
        <div class="home-indicator"></div>
      </div>
    `;

    window.filterCat = (c) => {
      currentProjectCategory = c;
      router.handleHashChange();
    };
  });

  // ─────────────────────────────────────────────
  // 6. SUMMIT 2026 (Prestige Diaspora Forum)
  // ─────────────────────────────────────────────
  router.register('/summit', () => {
    const s = store.state.summit;
    const poll = s.livePoll;

    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Sommet Diaspora</h1>
          <div style="width: 38px;"></div>
        </div>

        <div class="screen-body no-nav">
          <div class="summit-hero">
            <span class="badge" style="background: rgba(255,255,255,0.15); color: #fff; margin-bottom: 10px;">${s.edition}</span>
            <h2 style="font-size: 24px; font-weight: 800; line-height: 1.1; margin-bottom: 6px;">${s.title}</h2>
            <div style="font-size: 12.5px; opacity: 0.85; margin-bottom: 16px;">
              <div>${icon('calendar', 14, 'var(--sand-gold)')} ${s.dates} · Houmt Souk</div>
              <div style="margin-top: 2px;">${icon('users', 14, 'var(--sand-gold)')} ${s.attendeesCount} participants inscrits</div>
            </div>

            <button class="btn btn-primary btn-block btn-sm" style="background: #fff; color: var(--ink);" onclick="adpStore.toggleSummitRegistration(); adpRouter.handleHashChange(); showToast(adpStore.state.summit.isRegistered ? 'Inscription confirmée !' : 'Inscription annulée', 'info');">
              ${icon('checkCircle', 16, 'var(--ink)')}
              ${s.isRegistered ? 'Vous participez au Sommet' : 'Confirmer ma présence'}
            </button>
          </div>

          <!-- Interactive Live Poll -->
          <div class="section-bar">
            <span class="section-heading">Sondage des Adhérents</span>
            <span class="badge badge-ocean" style="font-size: 10px;">EN DIRECT</span>
          </div>

          <div class="card" style="margin-bottom: 20px;">
            <h4 style="font-size: 14px; font-weight: 800; margin-bottom: 12px;">${poll.question}</h4>
            <div style="display: flex; flex-direction: column; gap: 8px;">
              ${poll.options.map(opt => {
                const totalVotes = poll.options.reduce((a, b) => a + b.votes, 0);
                const pct = ((opt.votes / totalVotes) * 100).toFixed(0);
                const isSelected = poll.userVoted === opt.id;
                return `
                  <div class="choice-card ${isSelected ? 'selected' : ''}" style="padding: 10px 14px;" onclick="votePoll('${opt.id}')">
                    <div style="flex: 1;">
                      <div style="font-size: 13px; font-weight: 700;">${opt.label}</div>
                      <div class="progress-container" style="margin-top: 6px;">
                        <div class="progress-fill" style="width: ${pct}%;"></div>
                      </div>
                    </div>
                    <div style="font-size: 12px; font-weight: 800; color: var(--ocean); margin-left: 12px;">${pct}%</div>
                  </div>
                `;
              }).join('')}
            </div>
          </div>

          <!-- Tracks -->
          <div class="section-bar">
            <span class="section-heading">Tables Rondes</span>
          </div>
          ${s.tracks.map(t => `
            <div class="card" style="padding: 13px 15px; margin-bottom: 10px;">
              <div style="display: flex; gap: 12px; align-items: center;">
                <div style="width: 38px; height: 38px; border-radius: 12px; background: var(--canvas-soft); display: flex; align-items: center; justify-content: center; color: var(--ocean);">
                  ${icon('mic', 18, 'var(--ocean)')}
                </div>
                <div>
                  <div style="font-size: 11px; color: var(--terracotta); font-weight: 700;">${t.time}</div>
                  <h4 style="font-size: 13.5px; font-weight: 800;">${t.title}</h4>
                  <div style="font-size: 11.5px; color: var(--muted);">Avec ${t.speaker}</div>
                </div>
              </div>
            </div>
          `).join('')}
        </div>
        <div class="home-indicator"></div>
      </div>
    `;

    window.votePoll = (optId) => {
      store.voteSummitPoll(optId);
      router.handleHashChange();
      showToast('Vote enregistré !', 'success');
    };
  });

  // ─────────────────────────────────────────────
  // 7. E-PASS DIGITAL
  // ─────────────────────────────────────────────
  router.register('/epass', () => {
    const user = store.state.currentUser;

    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <h1 class="app-bar-title">e-Pass Membre</h1>
          <button class="icon-btn" onclick="showToast('Lien du pass copié', 'success')">${icon('share', 18)}</button>
        </div>

        <div class="screen-body">
          <div class="pass-card-wrap" style="margin-top: 4px;">
            <div class="digital-pass">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <div style="display: flex; align-items: center; gap: 8px;">
                  ${icon('compass', 22, 'var(--sand-gold)')}
                  <span style="font-family: 'Barlow Condensed'; font-size: 18px; font-weight: 800; letter-spacing: 0.5px;">ADP DJERBA</span>
                </div>
                <span class="badge" style="background: rgba(255,255,255,0.16); color: #fff;">${user.tier}</span>
              </div>

              <div style="text-align: left; margin: 18px 0;">
                <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 1px; opacity: 0.7;">Adhérent Officiel</div>
                <div style="font-size: 22px; font-weight: 800; letter-spacing: 0.3px;">${user.firstName} ${user.lastName}</div>
                <div style="font-size: 12px; font-family: monospace; color: var(--sand-gold); margin-top: 2px;">${user.memberNumber}</div>
              </div>

              <div style="display: flex; justify-content: space-between; align-items: flex-end; border-top: 1px solid rgba(255,255,255,0.12); padding-top: 10px;">
                <div style="text-align: left;">
                  <div style="font-size: 9px; opacity: 0.6; text-transform: uppercase;">Valable jusqu'au</div>
                  <div style="font-size: 12.5px; font-weight: 700;">${user.validUntil}</div>
                </div>
                <div style="display: flex; align-items: center; gap: 4px; font-size: 11px; color: #6ee7b7; font-weight: 700;">
                  ${icon('checkCircle', 13, '#6ee7b7')} CERTIFIÉ
                </div>
              </div>
            </div>
          </div>

          <!-- QR Code Box -->
          <div class="card" style="margin-top: 18px; text-align: center; padding: 18px;">
            <div style="width: 130px; height: 130px; background: #fff; border-radius: 12px; margin: 0 auto 10px auto; border: 1px solid var(--border); display: flex; align-items: center; justify-content: center;">
              <svg width="100" height="100" viewBox="0 0 100 100" fill="#0E2129">
                <rect x="0" y="0" width="30" height="30" rx="3"/>
                <rect x="5" y="5" width="20" height="20" fill="#fff"/>
                <rect x="10" y="10" width="10" height="10"/>
                <rect x="70" y="0" width="30" height="30" rx="3"/>
                <rect x="75" y="5" width="20" height="20" fill="#fff"/>
                <rect x="80" y="10" width="10" height="10"/>
                <rect x="0" y="70" width="30" height="30" rx="3"/>
                <rect x="5" y="75" width="20" height="20" fill="#fff"/>
                <rect x="10" y="80" width="10" height="10"/>
                <rect x="40" y="10" width="10" height="20"/>
                <rect x="50" y="40" width="20" height="10"/>
                <rect x="40" y="70" width="20" height="20"/>
                <rect x="70" y="40" width="10" height="20"/>
                <rect x="80" y="70" width="20" height="10"/>
              </svg>
            </div>
            <div style="font-size: 13px; font-weight: 800; color: var(--ink);">Scanner pour authentification</div>
            <div style="font-size: 11px; color: var(--muted); margin-top: 2px;">Signé cryptographiquement (HMAC SHA-256)</div>
          </div>

          <div style="display: flex; gap: 10px; margin-top: 14px;">
            <button class="btn btn-primary btn-block btn-sm" onclick="showToast('Ajouté à votre Wallet', 'success')">
              ${icon('wallet', 16, '#fff')} Ajouter au Wallet
            </button>
            <button class="btn btn-secondary btn-block btn-sm" onclick="showToast('Attestation PDF générée', 'info')">
              ${icon('download', 16)} Attestation PDF
            </button>
          </div>
        </div>
        ${getBottomNavHtml('/epass')}
        <div class="home-indicator"></div>
      </div>
    `;
  });

  // ─────────────────────────────────────────────
  // 8. DONATE SCREEN
  // ─────────────────────────────────────────────
  router.register('/donate', (params) => {
    const defaultProject = params.projectId 
      ? store.state.projects.find(p => p.id === params.projectId) 
      : store.state.projects[0];

    let selectedAmount = 50;
    let selectedFrequency = 'oneOff';

    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Faire un don</h1>
          <div style="width: 38px;"></div>
        </div>

        <div class="screen-body no-nav">
          <div style="display: flex; background: var(--surface); border: 1px solid var(--border); border-radius: var(--r-pill); padding: 3px; margin-bottom: 16px;">
            <div id="freq-one" style="flex: 1; text-align: center; padding: 8px 0; border-radius: var(--r-pill); font-size: 13px; font-weight: 700; background: var(--ink); color: #fff; cursor: pointer;" onclick="setDonationFrequency('oneOff')">
              Don ponctuel
            </div>
            <div id="freq-month" style="flex: 1; text-align: center; padding: 8px 0; border-radius: var(--r-pill); font-size: 13px; font-weight: 700; color: var(--muted); cursor: pointer;" onclick="setDonationFrequency('monthly')">
              Don mensuel
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Projet ciblé</label>
            <select class="form-control no-icon" id="donate-project-select">
              <option value="general">Fonds général — Affectation prioritaire ADP</option>
              ${store.state.projects.map(p => `
                <option value="${p.id}" ${defaultProject && defaultProject.id === p.id ? 'selected' : ''}>${p.title}</option>
              `).join('')}
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Montant du don</label>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;">
              <div class="choice-card" style="padding: 12px 6px; justify-content: center; font-weight: 800; font-size: 16px;" onclick="chooseAmt(20, this)">20 €</div>
              <div class="choice-card selected" style="padding: 12px 6px; justify-content: center; font-weight: 800; font-size: 16px;" onclick="chooseAmt(50, this)">50 €</div>
              <div class="choice-card" style="padding: 12px 6px; justify-content: center; font-weight: 800; font-size: 16px;" onclick="chooseAmt(100, this)">100 €</div>
              <div class="choice-card" style="padding: 12px 6px; justify-content: center; font-weight: 800; font-size: 16px;" onclick="chooseAmt(250, this)">250 €</div>
              <div class="choice-card" style="padding: 12px 6px; justify-content: center; font-weight: 800; font-size: 16px;" onclick="chooseAmt(500, this)">500 €</div>
              <div class="choice-card" style="padding: 12px 6px; justify-content: center; font-weight: 800; font-size: 14px;" onclick="chooseAmt('custom', this)">Autre</div>
            </div>
            <div id="custom-amt-box" style="display: none; margin-top: 8px;">
              <input type="number" class="form-control no-icon" id="custom-amt-input" placeholder="Entrez le montant en €" min="5">
            </div>
          </div>

          <!-- Tax Benefit Pill -->
          <div class="card card-soft" style="margin: 16px 0; padding: 12px 14px;">
            <div style="display: flex; gap: 8px; align-items: center;">
              ${icon('receipt', 20, 'var(--terracotta)')}
              <div>
                <div style="font-size: 13px; font-weight: 800; color: var(--ink);" id="tax-text">Ce don ne vous coûte que 17 €</div>
                <div style="font-size: 11px; color: var(--muted);">Après déduction fiscale de 66% pour les résidents en France</div>
              </div>
            </div>
          </div>

          <!-- Anonymous Option -->
          <div class="card" style="display: flex; align-items: center; justify-content: space-between; padding: 12px 14px; margin-bottom: 20px;">
            <div>
              <div style="font-size: 13px; font-weight: 700;">Don anonyme</div>
              <div style="font-size: 11px; color: var(--muted);">Masquer mon nom sur la liste publique</div>
            </div>
            <label class="switch">
              <input type="checkbox" id="anon-check">
              <span class="slider"></span>
            </label>
          </div>

          <button class="btn btn-terracotta btn-block" id="donate-submit-btn">
            Confirmer le don de <span id="donate-btn-label">50 €</span> ${icon('heart', 16, '#fff')}
          </button>
        </div>
        <div class="home-indicator"></div>
      </div>
    `;

    window.setDonationFrequency = (freq) => {
      selectedFrequency = freq;
      const oneEl = document.getElementById('freq-one');
      const monthEl = document.getElementById('freq-month');
      if (freq === 'monthly') {
        monthEl.style.background = 'var(--ink)';
        monthEl.style.color = '#fff';
        oneEl.style.background = 'transparent';
        oneEl.style.color = 'var(--muted)';
        document.getElementById('donate-btn-label').textContent = `${selectedAmount} € / mois`;
      } else {
        oneEl.style.background = 'var(--ink)';
        oneEl.style.color = '#fff';
        monthEl.style.background = 'transparent';
        monthEl.style.color = 'var(--muted)';
        document.getElementById('donate-btn-label').textContent = `${selectedAmount} €`;
      }
    };

    window.chooseAmt = (amt, el) => {
      document.querySelectorAll('.choice-card').forEach(c => c.classList.remove('selected'));
      el.classList.add('selected');
      const customBox = document.getElementById('custom-amt-box');
      if (amt === 'custom') {
        customBox.style.display = 'block';
        document.getElementById('custom-amt-input').focus();
      } else {
        customBox.style.display = 'none';
        selectedAmount = amt;
        updateTax(amt);
      }
    };

    function updateTax(amt) {
      const real = (amt * 0.34).toFixed(0);
      document.getElementById('tax-text').textContent = `Ce don ne vous coûte que ${real} €`;
      document.getElementById('donate-btn-label').textContent = selectedFrequency === 'monthly' ? `${amt} € / mois` : `${amt} €`;
    }

    document.getElementById('donate-submit-btn').addEventListener('click', () => {
      const prjId = document.getElementById('donate-project-select').value;
      store.addDonation(prjId, selectedAmount);
      router.navigate('/payment-return', {
        checkoutIntentId: 'ADP-DON-' + Date.now(),
        amount: selectedAmount,
        type: 'donation'
      });
    });
  });

  // ─────────────────────────────────────────────
  // 9. MEMBERSHIP SCREEN
  // ─────────────────────────────────────────────
  router.register('/membership/start', () => {
    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Adhésion 2026</h1>
          <div style="width: 38px;"></div>
        </div>

        <div class="screen-body no-nav">
          <p class="onboarding-sub" style="margin-bottom: 16px;">
            Participez activement aux décisions statutaires et portez des projets pour Djerba.
          </p>

          <div class="card" style="margin-bottom: 12px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <span class="badge badge-neutral">STANDARD</span>
              <span style="font-size: 20px; font-weight: 800;">30 € <span style="font-size: 12px; color: var(--muted);">/an</span></span>
            </div>
            <h4 style="font-size: 15px; font-weight: 800;">Adhérent Actif</h4>
            <p style="font-size: 12px; color: var(--muted); margin: 4px 0 12px 0;">Droit de vote à l'AG, e-Pass officiel et accès aux comités.</p>
            <button class="btn btn-primary btn-block btn-sm" onclick="chooseMembership('Adhérent Actif', 30)">Adhérer</button>
          </div>

          <div class="card" style="margin-bottom: 12px; border: 2px solid var(--ink);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <span class="badge badge-terracotta">BIENFAITEUR</span>
              <span style="font-size: 20px; font-weight: 800; color: var(--terracotta);">100 € <span style="font-size: 12px; color: var(--muted);">/an</span></span>
            </div>
            <h4 style="font-size: 15px; font-weight: 800;">Membre Bienfaiteur</h4>
            <p style="font-size: 12px; color: var(--muted); margin: 4px 0 12px 0;">Soutien stratégique, mention d'honneur et invitation au Gala.</p>
            <button class="btn btn-terracotta btn-block btn-sm" onclick="chooseMembership('Membre Bienfaiteur', 100)">Souscrire Bienfaiteur</button>
          </div>

          <div class="card" style="margin-bottom: 12px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <span class="badge badge-neutral">JEUNESSE</span>
              <span style="font-size: 18px; font-weight: 800;">15 € <span style="font-size: 12px; color: var(--muted);">/an</span></span>
            </div>
            <h4 style="font-size: 14.5px; font-weight: 800;">Étudiant & Moins de 26 ans</h4>
            <p style="font-size: 12px; color: var(--muted); margin: 4px 0 12px 0;">Tarif solidaire pour impliquer la jeunesse djerbienne.</p>
            <button class="btn btn-secondary btn-block btn-sm" onclick="chooseMembership('Adhérent Jeune', 15)">Choisir</button>
          </div>
        </div>
        <div class="home-indicator"></div>
      </div>
    `;

    window.chooseMembership = (tier, price) => {
      store.state.currentUser.tier = tier;
      store.state.currentUser.status = 'Actif';
      store.saveState();
      router.navigate('/payment-return', {
        checkoutIntentId: 'ADP-COTIS-' + Date.now(),
        amount: price,
        type: 'membership'
      });
    };
  });

  // ─────────────────────────────────────────────
  // 10. NETWORKING DIRECTORY
  // ─────────────────────────────────────────────
  router.register('/networking', () => {
    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Annuaire Réseau</h1>
          <div style="width: 38px;"></div>
        </div>

        <div class="screen-body no-nav">
          <div class="form-group" style="margin-bottom: 14px;">
            <div class="input-wrapper">
              <span class="input-icon">${icon('search', 16, 'var(--muted)')}</span>
              <input type="text" class="form-control" id="net-search" placeholder="Rechercher par nom, ville, compétence...">
            </div>
          </div>

          <div id="net-list">
            ${store.state.membersDirectory.map(m => `
              <div class="card" style="padding: 14px; margin-bottom: 10px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                  <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="width: 40px; height: 40px; border-radius: 50%; background: var(--canvas-soft); border: 1px solid var(--border); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                      ${m.avatarText}
                    </div>
                    <div>
                      <h4 style="font-size: 14px; font-weight: 800;">${m.name}</h4>
                      <div style="font-size: 12px; color: var(--ocean); font-weight: 600;">${m.role}</div>
                      <div style="font-size: 11px; color: var(--muted); display:flex; align-items:center; gap:3px;">${icon('mapPin', 12, 'var(--muted)')} ${m.location}</div>
                    </div>
                  </div>
                  <button class="btn btn-secondary btn-sm" onclick="connectMember('${m.id}', '${m.name}')">
                    ${icon('mail', 14)}
                  </button>
                </div>
                ${m.skills ? `
                  <div style="display: flex; flex-wrap: wrap; gap: 4px; margin-top: 8px;">
                    ${m.skills.map(s => `<span class="badge badge-neutral" style="font-size: 10px;">${s}</span>`).join('')}
                  </div>
                ` : ''}
              </div>
            `).join('')}
          </div>
        </div>
        <div class="home-indicator"></div>
      </div>
    `;

    document.getElementById('net-search').addEventListener('input', (e) => {
      const q = e.target.value.toLowerCase();
      const filtered = store.state.membersDirectory.filter(m =>
        m.name.toLowerCase().includes(q) ||
        m.role.toLowerCase().includes(q) ||
        m.location.toLowerCase().includes(q) ||
        (m.skills && m.skills.some(s => s.toLowerCase().includes(q)))
      );
      document.getElementById('net-list').innerHTML = filtered.map(m => `
        <div class="card" style="padding: 14px; margin-bottom: 10px;">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="width: 40px; height: 40px; border-radius: 50%; background: var(--canvas-soft); border: 1px solid var(--border); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                ${m.avatarText}
              </div>
              <div>
                <h4 style="font-size: 14px; font-weight: 800;">${m.name}</h4>
                <div style="font-size: 12px; color: var(--ocean); font-weight: 600;">${m.role}</div>
                <div style="font-size: 11px; color: var(--muted); display:flex; align-items:center; gap:3px;">${icon('mapPin', 12, 'var(--muted)')} ${m.location}</div>
              </div>
            </div>
            <button class="btn btn-secondary btn-sm" onclick="connectMember('${m.id}', '${m.name}')">
              ${icon('mail', 14)}
            </button>
          </div>
          ${m.skills ? `
            <div style="display: flex; flex-wrap: wrap; gap: 4px; margin-top: 8px;">
              ${m.skills.map(s => `<span class="badge badge-neutral" style="font-size: 10px;">${s}</span>`).join('')}
            </div>
          ` : ''}
        </div>
      `).join('');
    });

    window.connectMember = (id, name) => {
      const msg = prompt(`Envoyer une demande d'introduction à ${name} :\n(Vos coordonnées directes ne seront partagées qu'après son accord)`);
      if (msg !== null) {
        store.sendConnectionRequest(id, msg);
        showToast(`Demande transmise à ${name} en toute confidentialité !`, 'success');
      }
    };
  });

  // ─────────────────────────────────────────────
  // 11. PROFILE SCREEN & RGPD
  // ─────────────────────────────────────────────
  router.register('/profile', () => {
    const user = store.state.currentUser;

    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <h1 class="app-bar-title">Mon Profil</h1>
          <button class="icon-btn" onclick="showToast('Profil synchronisé', 'info')">${icon('compass', 16)}</button>
        </div>

        <div class="screen-body">
          <div style="display: flex; flex-direction: column; align-items: center; text-align: center; padding: 10px 0 20px 0;">
            <div class="home-user-avatar" style="width: 72px; height: 72px; font-size: 24px; margin-bottom: 8px;">
              ${user.firstName[0]}${user.lastName[0]}
            </div>
            <h2 style="font-size: 19px; font-weight: 800;">${user.firstName} ${user.lastName}</h2>
            <div style="font-size: 12.5px; color: var(--muted);">${user.email}</div>
            <div style="display: flex; gap: 6px; margin-top: 8px;">
              <span class="badge badge-ocean">${user.tier}</span>
              <span class="badge badge-neutral">${user.country}</span>
            </div>
          </div>

          <div style="display: flex; flex-direction: column; gap: 8px;">
            <div class="choice-card" style="padding: 14px 16px;">
              <div>
                <div style="font-size: 13.5px; font-weight: 700;">Visibilité dans l'Annuaire</div>
                <div style="font-size: 11.5px; color: var(--muted);">Visible par les autres membres</div>
              </div>
              <label class="switch">
                <input type="checkbox" id="prof-dir-toggle" ${user.directoryVisible ? 'checked' : ''}>
                <span class="slider"></span>
              </label>
            </div>

            <div class="choice-card" style="padding: 14px 16px;" onclick="adpRouter.navigate('/notifications')">
              <div>
                <div style="font-size: 13.5px; font-weight: 700;">Notifications & Alertes</div>
                <div style="font-size: 11.5px; color: var(--muted);">${user.notificationsCount} non lues</div>
              </div>
              ${icon('arrowRight', 14, 'var(--muted)')}
            </div>

            <div class="choice-card" style="padding: 14px 16px;" onclick="exportData()">
              <div>
                <div style="font-size: 13.5px; font-weight: 700;">Exporter mes données (RGPD)</div>
                <div style="font-size: 11.5px; color: var(--muted);">Format JSON conforme art. 20</div>
              </div>
              ${icon('download', 16, 'var(--muted)')}
            </div>

            <div class="choice-card" style="padding: 14px 16px; margin-top: 10px; border-color: rgba(212, 98, 56, 0.3);" onclick="logoutUser()">
              <div>
                <div style="font-size: 13.5px; font-weight: 700; color: var(--terracotta);">Déconnexion</div>
                <div style="font-size: 11.5px; color: var(--muted);">Quitter la session</div>
              </div>
              ${icon('signout', 18, 'var(--terracotta)')}
            </div>
          </div>
        </div>
        ${getBottomNavHtml('/profile')}
        <div class="home-indicator"></div>
      </div>
    `;

    document.getElementById('prof-dir-toggle').addEventListener('change', () => {
      store.toggleDirectoryVisible();
      showToast(store.state.currentUser.directoryVisible ? 'Visible dans l\'annuaire' : 'Masqué de l\'annuaire', 'success');
    });

    window.exportData = () => {
      const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(store.exportUserData());
      const dl = document.createElement('a');
      dl.setAttribute("href", dataStr);
      dl.setAttribute("download", "adp_donnees_personnelles.json");
      dl.click();
      showToast('Export RGPD téléchargé !', 'success');
    };

    window.logoutUser = () => {
      store.logout();
      showToast('Déconnecté', 'info');
      router.navigate('/auth/login');
    };
  });

  // ─────────────────────────────────────────────
  // 12. EVENTS & GATHERINGS
  // ─────────────────────────────────────────────
  router.register('/events', () => {
    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Agenda ADP</h1>
          <div style="width: 38px;"></div>
        </div>

        <div class="screen-body no-nav">
          <div class="card" style="background: var(--ink); color: #fff; margin-bottom: 16px; cursor: pointer;" onclick="adpRouter.navigate('/summit')">
            <span class="badge" style="background: rgba(255,255,255,0.15); color: #fff; margin-bottom: 4px;">ÉVÉNEMENT PHARE</span>
            <h3 style="font-size: 16px; font-weight: 800; margin-top: 4px;">Djerba Diaspora Summit 2026</h3>
            <p style="font-size: 12px; opacity: 0.85; margin: 4px 0 10px 0;">18-20 Décembre · Houmt Souk · 3ème édition</p>
            <div style="font-size: 12px; color: var(--sand-gold); font-weight: 700;">Découvrir le programme →</div>
          </div>

          <div class="section-bar">
            <span class="section-heading">Prochains Rendez-vous</span>
          </div>

          ${store.state.events.map(e => `
            <div class="card" style="padding: 14px; margin-bottom: 10px;">
              <div style="display: flex; gap: 12px;">
                <div style="background: var(--canvas-soft); border: 1px solid var(--border); border-radius: var(--r-md); padding: 8px 12px; text-align: center; height: fit-content; min-width: 54px;">
                  <div style="font-size: 20px; font-weight: 800; color: var(--terracotta); line-height: 1;">${e.day}</div>
                  <div style="font-size: 10.5px; font-weight: 800; color: var(--ink);">${e.month}</div>
                </div>
                <div style="flex: 1;">
                  <h3 style="font-size: 14.5px; font-weight: 800; margin-bottom: 2px;">${e.title}</h3>
                  <div style="font-size: 11.5px; color: var(--muted);">${icon('calendar', 12, 'var(--muted)')} ${e.time}</div>
                  <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 10px;">${icon('mapPin', 12, 'var(--muted)')} ${e.location}</div>
                  
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 11.5px; color: var(--muted);">${e.participants} inscrits</span>
                    <button class="btn btn-sm ${e.isRsvp ? 'btn-secondary' : 'btn-primary'}" onclick="adpStore.toggleEventRsvp('${e.id}'); adpRouter.handleHashChange();">
                      ${e.isRsvp ? 'Inscrit ✓' : 'S’inscrire'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          `).join('')}
        </div>
        <div class="home-indicator"></div>
      </div>
    `;
  });

  // ─────────────────────────────────────────────
  // 13. NEWS
  // ─────────────────────────────────────────────
  router.register('/news', () => {
    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Actualités</h1>
          <div style="width: 38px;"></div>
        </div>

        <div class="screen-body no-nav">
          ${store.state.news.map(n => `
            <div class="card" style="padding: 16px; margin-bottom: 12px;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <span class="badge badge-ocean" style="font-size: 10px;">${n.category}</span>
                <span style="font-size: 11px; color: var(--muted);">${n.date} · ${n.readTime}</span>
              </div>
              <h3 style="font-size: 15.5px; font-weight: 800; margin-bottom: 4px;">${n.title}</h3>
              <p style="font-size: 12.5px; color: var(--muted); line-height: 1.45; margin-bottom: 12px;">${n.summary}</p>
              <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11.5px;">
                <span style="color: var(--ink); font-weight: 700;">Par ${n.author}</span>
                <button class="btn btn-secondary btn-sm" onclick="showToast('Article partagé', 'info')">
                  ${icon('share', 14)}
                </button>
              </div>
            </div>
          `).join('')}
        </div>
        <div class="home-indicator"></div>
      </div>
    `;
  });

  // ─────────────────────────────────────────────
  // 14. NOTIFICATIONS
  // ─────────────────────────────────────────────
  router.register('/notifications', () => {
    appContainer.innerHTML = `
      <div class="screen">
        ${getStatusBarHtml(false)}
        <div class="app-bar">
          <button class="icon-btn" onclick="window.history.back()">${icon('arrowLeft', 16)}</button>
          <h1 class="app-bar-title" style="font-size: 22px;">Notifications</h1>
          <button class="icon-btn" onclick="adpStore.markAllNotificationsRead(); adpRouter.handleHashChange(); showToast('Toutes lues', 'info');">
            ${icon('checkCircle', 18)}
          </button>
        </div>

        <div class="screen-body no-nav">
          ${store.state.notifications.map(n => `
            <div class="card" style="padding: 13px 15px; margin-bottom: 8px; ${n.unread ? 'border-left: 3px solid var(--ocean);' : ''}">
              <div style="display: flex; justify-content: space-between; margin-bottom: 3px;">
                <span style="font-size: 13.5px; font-weight: 800;">${n.title}</span>
                <span style="font-size: 11px; color: var(--muted);">${n.time}</span>
              </div>
              <p style="font-size: 12px; color: var(--muted); line-height: 1.4;">${n.message}</p>
            </div>
          `).join('')}
        </div>
        <div class="home-indicator"></div>
      </div>
    `;
  });

  // ─────────────────────────────────────────────
  // 15. PAYMENT RETURN SCREEN
  // ─────────────────────────────────────────────
  router.register('/payment-return', (params) => {
    const isDonation = params.type === 'donation';
    const amount = params.amount || '50';

    appContainer.innerHTML = `
      <div class="screen" style="padding: 24px 20px; text-align: center; justify-content: center; align-items: center;">
        ${getStatusBarHtml(false)}
        
        <div style="width: 72px; height: 72px; border-radius: 50%; background: var(--success-soft); color: var(--success); display: flex; align-items: center; justify-content: center; margin: 40px auto 16px auto;">
          ${icon('check', 36, 'var(--success)')}
        </div>

        <h1 class="onboarding-headline" style="font-size: 28px; margin-bottom: 6px;">Merci pour votre engagement</h1>
        <p class="onboarding-sub" style="max-width: 290px; margin-bottom: 24px;">
          ${isDonation ? `Votre don de ${amount} € a bien été pris en compte. Votre reçu fiscal est prêt.` : `Votre adhésion annuelle (${amount} €) est active. Votre e-Pass a été actualisé.`}
        </p>

        <div class="card card-soft" style="width: 100%; text-align: left; padding: 14px 16px; margin-bottom: 26px;">
          <div style="display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 6px;">
            <span style="color: var(--muted);">Référence</span>
            <span style="font-family: monospace; font-weight: 700;">${params.checkoutIntentId || 'ADP-REF-2026'}</span>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 12px;">
            <span style="color: var(--muted);">Statut</span>
            <span style="color: var(--success); font-weight: 800;">Validé & Synchronisé</span>
          </div>
        </div>

        <button class="btn btn-primary btn-block" onclick="adpRouter.navigate('/epass')">
          Accéder à mon e-Pass ${icon('arrowRight', 16, '#fff')}
        </button>
        <button class="btn btn-secondary btn-block" style="margin-top: 10px;" onclick="adpRouter.navigate('/home')">
          Retour à l'accueil
        </button>
        <div class="home-indicator"></div>
      </div>
    `;
  });

  // ── Sync Selector Dropdown ──
  router.onRouteChanged = (path) => {
    const select = document.getElementById('screen-selector');
    if (select) select.value = path;
  };

  // ── Init ──
  renderToolbar();
  router.init('/home');
});
