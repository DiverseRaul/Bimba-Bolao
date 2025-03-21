<template>
  <div class="DASHBOARD_CONTAINER">
    <header class="DASHBOARD_HEADER">
      <h1>Bimba Bolão</h1>
      <div class="HEADER_ACTIONS">
        <button class="THEME_BUTTON" @click="toggleTheme">
          <span v-if="IS_DARK_MODE">☀️</span>
          <span v-else>🌙</span>
        </button>
        <button class="LOGOUT_BUTTON" @click="LOGOUT">
          {{ CURRENT_LANGUAGE.LOGOUT }}
        </button>
      </div>
    </header>
    
    <main class="DASHBOARD_CONTENT">
      <div class="DASHBOARD_CARD">
        <h2>{{ CURRENT_LANGUAGE.WELCOME }}</h2>
        <p>{{ CURRENT_LANGUAGE.DASHBOARD_MESSAGE }}</p>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: 'DashboardPage',
  data() {
    return {
      CURRENT_LANGUAGE: {
        WELCOME: 'Welcome to Bimba Bolão',
        DASHBOARD_MESSAGE: 'Your soccer prediction platform is ready!',
        LOGOUT: 'Logout'
      }
    }
  },
  computed: {
    IS_DARK_MODE() {
      return this.$root.isDarkMode ? this.$root.isDarkMode() : false
    }
  },
  methods: {
    async LOGOUT() {
      await this.$supabase.auth.signOut()
      this.$router.push('/login')
    },
    toggleTheme() {
      if (this.$root.toggleDarkMode) {
        this.$root.toggleDarkMode()
      }
    }
  }
}
</script>

<style scoped>
.DASHBOARD_CONTAINER {
  min-height: 100vh;
  background-color: var(--bg-secondary);
}

.DASHBOARD_HEADER {
  background-color: var(--accent-primary);
  color: white;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.DASHBOARD_HEADER h1 {
  font-size: 24px;
  font-weight: 700;
  margin: 0;
}

.HEADER_ACTIONS {
  display: flex;
  align-items: center;
  gap: 12px;
}

.THEME_BUTTON {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 5px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  background-color: rgba(255, 255, 255, 0.15);
  transition: background-color 0.2s;
}

.THEME_BUTTON:hover {
  background-color: rgba(255, 255, 255, 0.25);
}

.LOGOUT_BUTTON {
  background-color: transparent;
  color: white;
  border: 1px solid white;
  border-radius: 6px;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.LOGOUT_BUTTON:hover {
  background-color: white;
  color: var(--accent-primary);
}

.DASHBOARD_CONTENT {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px;
}

.DASHBOARD_CARD {
  background-color: var(--card-bg);
  border-radius: 12px;
  box-shadow: var(--card-shadow);
  padding: 30px;
  margin-bottom: 24px;
}

.DASHBOARD_CARD h2 {
  font-size: 24px;
  color: var(--accent-primary);
  margin-bottom: 16px;
}

.DASHBOARD_CARD p {
  font-size: 16px;
  color: var(--text-secondary);
  line-height: 1.5;
}
</style>
