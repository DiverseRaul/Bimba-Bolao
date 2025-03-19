<template>
  <div class="DASHBOARD_CONTAINER">
    <header class="DASHBOARD_HEADER">
      <h1>Bimba Bolão</h1>
      <button class="LOGOUT_BUTTON" @click="LOGOUT">
        {{ CURRENT_LANGUAGE.LOGOUT }}
      </button>
    </header>
    
    <main class="DASHBOARD_CONTENT">
      <h2>{{ CURRENT_LANGUAGE.WELCOME }}</h2>
      <p>{{ CURRENT_LANGUAGE.DASHBOARD_MESSAGE }}</p>
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
  methods: {
    async LOGOUT() {
      await this.$supabase.auth.signOut()
      this.$router.push('/login')
    }
  }
}
</script>

<style scoped>
.DASHBOARD_CONTAINER {
  min-height: 100vh;
  background-color: #f3f4f6;
}

.DASHBOARD_HEADER {
  background-color: #1e3c72;
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

.LOGOUT_BUTTON {
  background-color: transparent;
  color: white;
  border: 1px solid white;
  border-radius: 4px;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.LOGOUT_BUTTON:hover {
  background-color: white;
  color: #1e3c72;
}

.DASHBOARD_CONTENT {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px;
}

.DASHBOARD_CONTENT h2 {
  font-size: 28px;
  color: #1e3c72;
  margin-bottom: 16px;
}

.DASHBOARD_CONTENT p {
  font-size: 16px;
  color: #4b5563;
  line-height: 1.5;
}
</style>
