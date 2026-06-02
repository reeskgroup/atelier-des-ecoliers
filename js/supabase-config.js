// Configuration Supabase — à remplir après création du projet sur supabase.com
// Voir l'issue GitHub "Configurer Supabase" pour les étapes détaillées.
window.SUPABASE_CONFIG = {
  url: "REPLACE_WITH_SUPABASE_URL",      // ex: "https://abcdefgh.supabase.co"
  anonKey: "REPLACE_WITH_SUPABASE_ANON_KEY", // clé publique (anon/public), pas la service_role
};
window.SUPABASE_CONFIGURED = !window.SUPABASE_CONFIG.url.startsWith("REPLACE_");
