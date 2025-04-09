<template>
  <div class="SETTINGS_CONTAINER">
    <page-loader :isVisible="PAGE_LOADING" />
    <app-header :USER="USER" currentPage="profile" />
    
    <main class="SETTINGS_CONTENT">
      <div class="SETTINGS_CARD">
        <h2>Settings</h2>
        
        <div class="SETTINGS_FORM">
          <div class="SETTINGS_SECTION">
            <h3>Appearance</h3>
            <div class="FORM_GROUP">
              <label for="theme">Theme</label>
              <div class="THEME_TOGGLE">
                <button 
                  class="THEME_BUTTON" 
                  :class="{ 'ACTIVE': IS_DARK_MODE }"
                  @click="setDarkMode(true)"
                >
                  Dark
                </button>
                <button 
                  class="THEME_BUTTON" 
                  :class="{ 'ACTIVE': !IS_DARK_MODE }"
                  @click="setDarkMode(false)"
                >
                  Light
                </button>
              </div>
            </div>
          </div>
          
          <div class="SETTINGS_SECTION PROFILE_SECTION">
            <h3>Profile</h3>
            <div class="FORM_GROUP">
              <label for="username">Username</label>
              <div class="INPUT_GROUP">
                <input 
                  type="text" 
                  id="username" 
                  v-model="USERNAME" 
                  class="FORM_INPUT"
                />
                <button 
                  class="PRIMARY_BUTTON" 
                  @click="updateUsername"
                  :disabled="IS_UPDATING"
                >
                  {{ IS_UPDATING ? 'Updating...' : 'Update Username' }}
                </button>
              </div>
            </div>
            <div v-if="SUCCESS_MESSAGE" class="SUCCESS_MESSAGE">
              {{ SUCCESS_MESSAGE }}
            </div>
            <div v-if="ERROR_MESSAGE" class="ERROR_MESSAGE">
              {{ ERROR_MESSAGE }}
            </div>
          </div>
          
          <div class="SETTINGS_SECTION">
            <h3>Account</h3>
            <div class="LOGOUT_SECTION">
              <button class="LOGOUT_BUTTON" @click="LOGOUT">
                Logout
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader.vue';
import PageLoader from '@/components/PageLoader.vue';

export default {
  name: 'SettingsPage',
  components: {
    AppHeader,
    PageLoader
  },
  data() {
    return {
      IS_DARK_MODE: this.$root.isDarkMode ? this.$root.isDarkMode() : localStorage.getItem('DARK_MODE') !== 'false',
      USERNAME: '',
      IS_UPDATING: false,
      SUCCESS_MESSAGE: '',
      ERROR_MESSAGE: '',
      PAGE_LOADING: true,
      USER: null
    }
  },
  mounted() {
    this.IS_DARK_MODE = this.$root.isDarkMode ? this.$root.isDarkMode() : localStorage.getItem('DARK_MODE') !== 'false'
    this.loadUserData()
    // Set a default USER object to ensure header buttons are visible immediately
    this.USER = { id: 'loading' }
    setTimeout(() => {
      this.PAGE_LOADING = false
    }, 1000)
  },
  methods: {
    setDarkMode(isDark) {
      const CURRENT_MODE = this.$root.isDarkMode ? this.$root.isDarkMode() : localStorage.getItem('DARK_MODE') !== 'false'
      if (isDark !== CURRENT_MODE) {
        if (this.$root.toggleDarkMode) {
          this.$root.toggleDarkMode()
          this.IS_DARK_MODE = isDark
        } else {
          console.error('Dark mode toggle function not found on $root')
          localStorage.setItem('DARK_MODE', isDark)
          this.IS_DARK_MODE = isDark
        }
      }
    },
    async loadUserData() {
      this.ERROR_MESSAGE = ''; // Clear previous errors
      try {
        const { data: { user }, error: userError } = await this.$supabase.auth.getUser();
        console.log('User object:', user);
        if (userError) {
          console.error('Error fetching user:', userError);
          throw new Error('Could not fetch authenticated user.');
        }
        if (!user) {
          console.log('No authenticated user found, redirecting to login.');
          this.$router.push('/login');
          return;
        }

        console.log('Fetching profile for user ID:', user.id);
        const { data: profileData, error: profileError } = await this.$supabase
          .from('USERS')
          .select('DISPLAY_NAME')
          .eq('ID', user.id)
          .single();

        console.log('Profile fetch result:', { profileData, profileError });

        if (profileError) {
          console.error('Supabase profile fetch error:', profileError);
          if (profileError.message.includes('security barrier')) {
            throw new Error('Failed to load profile due to permission restrictions (RLS).');
          } else {
            throw profileError;
          }
        }

        if (profileData) {
          this.USERNAME = profileData.DISPLAY_NAME || '';
        }
        // Set the USER object for the header
        this.USER = user;
      } catch (error) {
        console.error('Error loading user data:', error);
      }
    },
    async updateUsername() {
      if (!this.USERNAME || !this.USERNAME.trim()) {
        this.ERROR_MESSAGE = 'Username cannot be empty.';
        return;
      }
      this.IS_UPDATING = true;
      this.SUCCESS_MESSAGE = '';
      this.ERROR_MESSAGE = '';

      try {
        const { data: { user } } = await this.$supabase.auth.getUser();
        if (!user) throw new Error('User not authenticated');

        const { error } = await this.$supabase
          .from('USERS')
          .update({ DISPLAY_NAME: this.USERNAME.trim() })
          .eq('ID', user.id);

        if (error) throw error;

        this.SUCCESS_MESSAGE = 'Username updated successfully!';
      } catch (error) {
        console.error('Error updating username:', error);
        this.ERROR_MESSAGE = `Error updating username: ${error.message || String(error)}`;
      } finally {
        this.IS_UPDATING = false;
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
}

.SETTINGS_HEADER {
  display: none; /* Hide the old header */
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

.ERROR_MESSAGE {
  margin-top: 16px;
  padding: 12px;
  background-color: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
  color: var(--error-color);
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

.PROFILE_SECTION .FORM_GROUP {
  margin-bottom: 1rem;
}

.PROFILE_SECTION .INPUT_GROUP {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.PROFILE_SECTION .FORM_INPUT {
  flex-grow: 1;
}

.PROFILE_SECTION .PRIMARY_BUTTON {
  flex-shrink: 0;
}
</style>
