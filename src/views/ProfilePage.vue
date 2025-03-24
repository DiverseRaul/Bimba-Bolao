<template>
  <div class="SETTINGS_CONTAINER">
    <header class="SETTINGS_HEADER">
      <div class="HEADER_LOGO">
        <img src="../assets/logo.png" alt="Bimba Bolao" class="LOGO_IMAGE" />
        <h1>Bimba Bolao</h1>
      </div>
      <div class="HEADER_ACTIONS">
        <button class="NAV_BUTTON" @click="navigateToDashboard">
          {{ CURRENT_LANGUAGE.DASHBOARD }}
        </button>
      </div>
    </header>
    
    <main class="SETTINGS_CONTENT">
      <div class="SETTINGS_CARD">
        <h2>{{ CURRENT_LANGUAGE.SETTINGS_TITLE }}</h2>
        
        <div class="SETTINGS_FORM">
          <div class="SETTINGS_SECTION">
            <h3>{{ CURRENT_LANGUAGE.APPEARANCE }}</h3>
            <div class="FORM_GROUP">
              <label for="theme">{{ CURRENT_LANGUAGE.THEME }}</label>
              <div class="THEME_TOGGLE">
                <button 
                  class="THEME_BUTTON" 
                  :class="{ 'ACTIVE': IS_DARK_MODE }"
                  @click="setDarkMode(true)"
                >
                  {{ CURRENT_LANGUAGE.DARK }}
                </button>
                <button 
                  class="THEME_BUTTON" 
                  :class="{ 'ACTIVE': !IS_DARK_MODE }"
                  @click="setDarkMode(false)"
                >
                  {{ CURRENT_LANGUAGE.LIGHT }}
                </button>
              </div>
            </div>
          </div>
          
          <div class="SETTINGS_SECTION">
            <h3>{{ CURRENT_LANGUAGE.LANGUAGE_SETTINGS }}</h3>
            <div class="FORM_GROUP">
              <label for="language">{{ CURRENT_LANGUAGE.LANGUAGE }}</label>
              <select 
                id="language" 
                v-model="SELECTED_LANGUAGE" 
                class="FORM_INPUT"
                @change="changeLanguage"
              >
                <option value="en">English</option>
                <option value="pt">Português</option>
                <option value="es">Español</option>
              </select>
            </div>
          </div>
          
          <div class="SETTINGS_SECTION">
            <h3>{{ CURRENT_LANGUAGE.ACCOUNT }}</h3>
            <div class="FORM_GROUP">
              <label for="username">{{ CURRENT_LANGUAGE.USERNAME }}</label>
              <input 
                type="text" 
                id="username" 
                v-model="USERNAME" 
                class="FORM_INPUT"
              />
            </div>
            <div class="FORM_ACTIONS">
              <button 
                class="PRIMARY_BUTTON" 
                @click="updateUsername"
                :disabled="IS_UPDATING"
              >
                {{ IS_UPDATING ? CURRENT_LANGUAGE.UPDATING : CURRENT_LANGUAGE.UPDATE_USERNAME }}
              </button>
            </div>
            <div class="LOGOUT_SECTION">
              <button class="LOGOUT_BUTTON" @click="LOGOUT">
                {{ CURRENT_LANGUAGE.LOGOUT }}
              </button>
            </div>
          </div>
          
          <div v-if="SUCCESS_MESSAGE" class="SUCCESS_MESSAGE">
            {{ SUCCESS_MESSAGE }}
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: 'SettingsPage',
  data() {
    return {
      IS_DARK_MODE: localStorage.getItem('theme') === 'dark',
      SELECTED_LANGUAGE: localStorage.getItem('language') || 'en',
      USERNAME: '',
      IS_UPDATING: false,
      SUCCESS_MESSAGE: '',
      ERROR_MESSAGE: '',
      CURRENT_LANGUAGE: {
        SETTINGS_TITLE: 'Settings',
        APPEARANCE: 'Appearance',
        THEME: 'Theme',
        DARK: 'Dark',
        LIGHT: 'Light',
        LANGUAGE_SETTINGS: 'Language',
        LANGUAGE: 'Select Language',
        ACCOUNT: 'Account',
        USERNAME: 'Username',
        UPDATE_USERNAME: 'Update Username',
        UPDATING: 'Updating...',
        DASHBOARD: 'Dashboard',
        LOGOUT: 'Logout',
        SETTINGS_UPDATED: 'Settings updated successfully!',
        USERNAME_UPDATED: 'Username updated successfully!'
      }
    }
  },
  mounted() {
    this.loadUserData()
    this.applyTheme()
  },
  methods: {
    applyTheme() {
      if (this.IS_DARK_MODE) {
        document.body.classList.add('dark-mode')
        document.body.classList.remove('light-mode')
      } else {
        document.body.classList.remove('dark-mode')
        document.body.classList.add('light-mode')
      }
    },
    setDarkMode(isDark) {
      this.IS_DARK_MODE = isDark
      localStorage.setItem('theme', isDark ? 'dark' : 'light')
      this.applyTheme()
      this.SUCCESS_MESSAGE = this.CURRENT_LANGUAGE.SETTINGS_UPDATED
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        this.SUCCESS_MESSAGE = ''
      }, 3000)
    },
    changeLanguage() {
      // In a real app, this would update the i18n locale
      localStorage.setItem('language', this.SELECTED_LANGUAGE)
      this.SUCCESS_MESSAGE = this.CURRENT_LANGUAGE.SETTINGS_UPDATED
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        this.SUCCESS_MESSAGE = ''
      }, 3000)
    },
    async loadUserData() {
      try {
        // Get current user
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        // Get user profile from USERS table
        const { data, error } = await this.$supabase
          .from('USERS')
          .select('DISPLAY_NAME')
          .eq('ID', user.id)
          .single()
        
        if (!error && data) {
          this.USERNAME = data.DISPLAY_NAME || ''
        }
      } catch (error) {
        console.error('Error loading user data:', error)
      }
    },
    async updateUsername() {
      if (!this.USERNAME.trim()) {
        return
      }
      
      this.IS_UPDATING = true
      this.SUCCESS_MESSAGE = ''
      this.ERROR_MESSAGE = ''
      
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        const { error } = await this.$supabase
          .from('USERS')
          .update({
            DISPLAY_NAME: this.USERNAME
          })
          .eq('ID', user.id)
        
        if (error) throw error
        
        this.SUCCESS_MESSAGE = this.CURRENT_LANGUAGE.USERNAME_UPDATED
      } catch (error) {
        console.error('Error updating username:', error)
      } finally {
        this.IS_UPDATING = false
      }
    },
    navigateToDashboard() {
      this.$router.push('/dashboard')
    },
    async LOGOUT() {
      await this.$supabase.auth.signOut()
      this.$router.push('/login')
    }
  }
}
</script>

<style scoped>
.SETTINGS_CONTAINER {
  min-height: 100vh;
  background-color: var(--bg-primary);
  background-image: var(--pattern-overlay);
}

.SETTINGS_HEADER {
  background: rgba(23, 23, 23, 0.8);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: white;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.HEADER_LOGO {
  display: flex;
  align-items: center;
  gap: 12px;
}

.LOGO_IMAGE {
  width: 40px;
  height: 40px;
  object-fit: contain;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.SETTINGS_HEADER h1 {
  font-size: 24px;
  font-weight: 700;
  margin: 0;
  letter-spacing: 0.5px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.HEADER_ACTIONS {
  display: flex;
  align-items: center;
  gap: 12px;
}

.NAV_BUTTON {
  background-color: transparent;
  color: var(--text-primary);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 10px 18px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.NAV_BUTTON:hover {
  background-color: rgba(255, 255, 255, 0.05);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.SETTINGS_CONTENT {
  max-width: 800px;
  margin: 0 auto;
  padding: 40px 24px;
}

.SETTINGS_CARD {
  background-color: var(--card-bg);
  border-radius: 16px;
  box-shadow: var(--card-shadow);
  padding: 30px;
  margin-bottom: 24px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: card-appear 0.5s ease-out forwards;
}

@keyframes card-appear {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

.SETTINGS_CARD h2 {
  font-size: 24px;
  margin-bottom: 24px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  display: inline-block;
  font-weight: 700;
}

.SETTINGS_FORM {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.SETTINGS_SECTION {
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 24px;
}

.SETTINGS_SECTION:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.SETTINGS_SECTION h3 {
  font-size: 18px;
  margin-bottom: 16px;
  color: var(--text-primary);
  font-weight: 600;
}

.FORM_GROUP {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 16px;
}

.FORM_GROUP:last-child {
  margin-bottom: 0;
}

.FORM_GROUP label {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-secondary);
}

.FORM_INPUT {
  background-color: var(--input-bg);
  border: 1px solid var(--input-border);
  border-radius: 8px;
  padding: 12px 16px;
  font-size: 16px;
  color: var(--text-primary);
  transition: all 0.3s;
  width: 100%;
}

.FORM_INPUT:focus {
  border-color: var(--accent-primary);
  outline: none;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.3);
}

.THEME_TOGGLE {
  display: flex;
  gap: 8px;
}

.THEME_BUTTON {
  flex: 1;
  background-color: var(--input-bg);
  border: 1px solid var(--input-border);
  border-radius: 8px;
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s;
}

.THEME_BUTTON.ACTIVE {
  background-color: var(--accent-primary);
  color: white;
  border-color: var(--accent-primary);
}

.THEME_BUTTON:hover:not(.ACTIVE) {
  background-color: var(--input-border);
}

.LOGOUT_SECTION {
  margin-top: 8px;
}

.LOGOUT_BUTTON {
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--error-color);
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 8px;
  padding: 10px 18px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.LOGOUT_BUTTON:hover {
  background-color: rgba(239, 68, 68, 0.2);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.SUCCESS_MESSAGE {
  margin-top: 16px;
  padding: 12px;
  background-color: rgba(34, 197, 94, 0.1);
  border-radius: 6px;
  color: var(--success-color);
  font-size: 14px;
}

.PRIMARY_BUTTON {
  background-color: var(--accent-primary);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.PRIMARY_BUTTON:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 8px rgba(59, 130, 246, 0.25);
  background-color: var(--button-hover-bg);
  color: white;
}

.PRIMARY_BUTTON:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(59, 130, 246, 0.25);
}

.PRIMARY_BUTTON:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.FORM_ACTIONS {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
  margin-bottom: 24px;
}
</style>
