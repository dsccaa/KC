// 11Kölsch Website JavaScript

// Supabase-Konfiguration
const supabaseUrl = 'https://nrkjjukeracgbpvwbjam.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ya2pqdWtlcmFjZ2JwdndiamFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNTU2OTAsImV4cCI6MjA3MTYzMTY5MH0.9NtxeNVLNwcTSgNq6ug1aedvvz9oBC3SqRB3sahkhEU';

const supabase = window.supabase.createClient(supabaseUrl, supabaseKey);

// Globale Variablen
let currentUser = null;

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    checkAuthState();
});

// App initialisieren
function initializeApp() {
    console.log('🍺 11Kölsch Website initialisiert');
    
    // Smooth Scrolling für Navigation
    setupSmoothScrolling();
    
    // Intersection Observer für aktive Navigation
    setupIntersectionObserver();
}

// Event Listeners einrichten
function setupEventListeners() {
    // Auth Buttons
    document.getElementById('loginBtn').addEventListener('click', showLoginForm);
    document.getElementById('registerBtn').addEventListener('click', showRegisterForm);
    
    // Auth Forms
    document.getElementById('loginFormElement').addEventListener('submit', handleLogin);
    document.getElementById('registerFormElement').addEventListener('submit', handleRegister);
    
    // Contact Form
    document.getElementById('contactForm').addEventListener('submit', handleContactForm);
    
    // Modal schließen bei Klick außerhalb
    document.getElementById('authModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeAuthModal();
        }
    });
}

// Smooth Scrolling
function setupSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Intersection Observer für aktive Navigation
function setupIntersectionObserver() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const id = entry.target.getAttribute('id');
                navLinks.forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('href') === `#${id}`) {
                        link.classList.add('active');
                    }
                });
            }
        });
    }, {
        threshold: 0.3
    });
    
    sections.forEach(section => {
        observer.observe(section);
    });
}

// Auth State prüfen
async function checkAuthState() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            currentUser = user;
            updateAuthUI(true);
        } else {
            updateAuthUI(false);
        }
    } catch (error) {
        console.error('Auth State Check Error:', error);
        updateAuthUI(false);
    }
}

// Auth UI aktualisieren
function updateAuthUI(isAuthenticated) {
    const loginBtn = document.getElementById('loginBtn');
    const registerBtn = document.getElementById('registerBtn');
    
    if (isAuthenticated) {
        loginBtn.textContent = 'Profil';
        loginBtn.onclick = () => showProfile();
        registerBtn.style.display = 'none';
    } else {
        loginBtn.textContent = 'Anmelden';
        loginBtn.onclick = showLoginForm;
        registerBtn.style.display = 'inline-block';
    }
}

// Login Form anzeigen
function showLoginForm() {
    document.getElementById('authModal').style.display = 'flex';
    document.getElementById('loginForm').style.display = 'block';
    document.getElementById('registerForm').style.display = 'none';
}

// Register Form anzeigen
function showRegisterForm() {
    document.getElementById('authModal').style.display = 'flex';
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('registerForm').style.display = 'block';
}

// Auth Modal schließen
function closeAuthModal() {
    document.getElementById('authModal').style.display = 'none';
}

// Login verarbeiten
async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    
    try {
        showToast('Anmeldung läuft...', 'info');
        
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });
        
        if (error) {
            throw error;
        }
        
        currentUser = data.user;
        updateAuthUI(true);
        closeAuthModal();
        showToast('Erfolgreich angemeldet!', 'success');
        
    } catch (error) {
        console.error('Login Error:', error);
        showToast('Anmeldung fehlgeschlagen: ' + error.message, 'error');
    }
}

// Registrierung verarbeiten
async function handleRegister(e) {
    e.preventDefault();
    
    const firstName = document.getElementById('registerFirstName').value;
    const lastName = document.getElementById('registerLastName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    const passwordConfirm = document.getElementById('registerPasswordConfirm').value;
    
    // Passwort-Validierung
    if (password !== passwordConfirm) {
        showToast('Passwörter stimmen nicht überein', 'error');
        return;
    }
    
    if (password.length < 6) {
        showToast('Passwort muss mindestens 6 Zeichen lang sein', 'error');
        return;
    }
    
    try {
        showToast('Registrierung läuft...', 'info');
        
        const { data, error } = await supabase.auth.signUp({
            email: email,
            password: password,
            options: {
                data: {
                    first_name: firstName,
                    last_name: lastName
                }
            }
        });
        
        if (error) {
            throw error;
        }
        
        closeAuthModal();
        showToast('Registrierung erfolgreich! Bitte bestätige deine E-Mail.', 'success');
        
    } catch (error) {
        console.error('Register Error:', error);
        showToast('Registrierung fehlgeschlagen: ' + error.message, 'error');
    }
}

// Profil anzeigen
function showProfile() {
    if (currentUser) {
        showToast(`Willkommen, ${currentUser.email}!`, 'success');
        // Hier könnte eine Profil-Seite geöffnet werden
    }
}

// Kontaktformular verarbeiten
async function handleContactForm(e) {
    e.preventDefault();
    
    const name = document.getElementById('contactName').value;
    const email = document.getElementById('contactEmail').value;
    const message = document.getElementById('contactMessage').value;
    
    try {
        showToast('Nachricht wird gesendet...', 'info');
        
        // Hier würde normalerweise eine API-Anfrage an einen E-Mail-Service gesendet
        // Für Demo-Zwecke simulieren wir eine erfolgreiche Sendung
        
        setTimeout(() => {
            showToast('Nachricht erfolgreich gesendet!', 'success');
            document.getElementById('contactForm').reset();
        }, 1000);
        
    } catch (error) {
        console.error('Contact Form Error:', error);
        showToast('Fehler beim Senden der Nachricht', 'error');
    }
}

// Scroll-Funktionen
function scrollToDownload() {
    document.getElementById('download').scrollIntoView({
        behavior: 'smooth'
    });
}

function scrollToFeatures() {
    document.getElementById('features').scrollIntoView({
        behavior: 'smooth'
    });
}

// Download-Funktionen
function downloadIOS() {
    showToast('iOS App ist noch nicht verfügbar. Bald im App Store!', 'info');
    // Hier würde der Link zur iOS App stehen
}

// Toast Messages
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type}`;
    toast.classList.add('show');
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

// Auth State Changes überwachen
supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_IN') {
        currentUser = session.user;
        updateAuthUI(true);
        showToast('Erfolgreich angemeldet!', 'success');
    } else if (event === 'SIGNED_OUT') {
        currentUser = null;
        updateAuthUI(false);
        showToast('Erfolgreich abgemeldet!', 'info');
    }
});

// Service Worker für PWA (optional)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then((registration) => {
                console.log('SW registered: ', registration);
            })
            .catch((registrationError) => {
                console.log('SW registration failed: ', registrationError);
            });
    });
}

// Analytics (optional)
function trackEvent(eventName, properties = {}) {
    // Hier könnte Google Analytics oder ein anderer Analytics-Service integriert werden
    console.log('Event tracked:', eventName, properties);
}

// Performance Monitoring
window.addEventListener('load', () => {
    const loadTime = performance.now();
    console.log(`🍺 11Kölsch Website geladen in ${Math.round(loadTime)}ms`);
    trackEvent('page_load', { load_time: loadTime });
});
