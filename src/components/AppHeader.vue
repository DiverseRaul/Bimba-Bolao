<template>
  <header class="app-header">
    <div class="header-content">
      <div class="header-left">
        <div class="logo-container" @click="navigateToDashboard">
          <h1 class="site-title">Bimba Bolao</h1>
        </div>
      </div>
      <div class="header-actions" v-if="USER">
        <!-- Dashboard button - only visible when not on dashboard -->
        <button v-if="currentPage !== 'dashboard'" class="icon-button" title="Home" @click="navigateToDashboard">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
            <polyline points="9 22 9 12 15 12 15 22"></polyline>
          </svg>
        </button>
        
        <!-- Settings button - only visible when not on profile page -->
        <button v-if="currentPage !== 'profile'" class="icon-button" title="Settings" @click="navigateToProfile">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="3"></circle>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
          </svg>
        </button>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  name: 'AppHeader',
  props: {
    USER: {
      type: Object,
      required: true
    },
    currentPage: {
      type: String,
      default: ''
    }
  },
  methods: {
    navigateToDashboard() {
      this.$router.push('/dashboard')
    },
    navigateToProfile() {
      this.$router.push('/profile')
    }
  }
}
</script>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  height: 80px;
  background-color: var(--bg-dark);
  color: var(--text-primary);
  position: relative;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  width: 100%;
  position: sticky;
  top: 0;
  z-index: 100;
  margin-bottom: 24px;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  position: relative;
  z-index: 1;
  height: 100%;
}

.header-left {
  display: flex;
  align-items: center;
}

.logo-container {
  cursor: pointer;
  transition: transform 0.2s ease;
}

.logo-container:hover {
  transform: translateY(-2px);
}

.site-title {
  font-size: 24px;
  font-weight: 700;
  margin: 0;
  background: linear-gradient(45deg, var(--accent-primary), #ff9d00);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: 0.5px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  height: 100%;
}

.icon-button {
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.icon-button svg {
  width: 24px;
  height: 24px;
  transition: all 0.3s ease;
}

.icon-button:hover {
  background-color: var(--accent-primary); /* Orange background on hover */
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  border: 2px solid var(--accent-primary); /* Thicker orange border on hover */
}

.icon-button:hover svg {
  color: white; /* White icon on hover for better contrast */
  transform: scale(1.1); /* Slightly larger icon on hover */
}

.icon-button:active {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

@media (max-width: 768px) {
  .site-title {
    font-size: 20px;
  }
  
  .icon-button {
    width: 36px;
    height: 36px;
  }
}

@media (max-width: 480px) {
  .site-title {
    font-size: 18px;
  }
}
</style>
