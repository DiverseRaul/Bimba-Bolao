<template>
  <div class="SIGNUP_CONTAINER">
    <div class="SIGNUP_CARD">
      <div class="SIGNUP_HEADER">
        <h1>Bimba Bolão</h1>
        <p>{{ CURRENT_LANGUAGE.SIGNUP_SUBTITLE }}</p>
      </div>
      
      <div class="SIGNUP_FORM">
        <div class="FORM_GROUP">
          <label for="username">{{ CURRENT_LANGUAGE.USERNAME }}</label>
          <input 
            type="text" 
            id="username" 
            v-model="SIGNUP_FORM.USERNAME" 
            :placeholder="CURRENT_LANGUAGE.USERNAME_PLACEHOLDER"
          />
        </div>
        
        <div class="FORM_GROUP">
          <label for="email">{{ CURRENT_LANGUAGE.EMAIL }}</label>
          <input 
            type="email" 
            id="email" 
            v-model="SIGNUP_FORM.EMAIL" 
            :placeholder="CURRENT_LANGUAGE.EMAIL_PLACEHOLDER"
          />
        </div>
        
        <div class="FORM_GROUP">
          <label for="password">{{ CURRENT_LANGUAGE.PASSWORD }}</label>
          <input 
            type="password" 
            id="password" 
            v-model="SIGNUP_FORM.PASSWORD" 
            :placeholder="CURRENT_LANGUAGE.PASSWORD_PLACEHOLDER"
          />
        </div>
        
        <div class="FORM_GROUP">
          <label for="confirmPassword">{{ CURRENT_LANGUAGE.CONFIRM_PASSWORD }}</label>
          <input 
            type="password" 
            id="confirmPassword" 
            v-model="SIGNUP_FORM.CONFIRM_PASSWORD" 
            :placeholder="CURRENT_LANGUAGE.CONFIRM_PASSWORD_PLACEHOLDER"
          />
        </div>
        
        <div class="FORM_ACTIONS">
          <button 
            class="PRIMARY_BUTTON" 
            @click="REGISTER"
            :disabled="IS_LOADING || !IS_FORM_VALID"
          >
            <span v-if="IS_LOADING">{{ CURRENT_LANGUAGE.LOADING }}</span>
            <span v-else>{{ CURRENT_LANGUAGE.SIGNUP }}</span>
          </button>
        </div>
        
        <div class="FORM_FOOTER">
          <p>
            {{ CURRENT_LANGUAGE.HAVE_ACCOUNT }} 
            <router-link to="/login">{{ CURRENT_LANGUAGE.LOGIN }}</router-link>
          </p>
        </div>
        
        <div v-if="ERROR_MESSAGE" class="ERROR_MESSAGE">
          {{ ERROR_MESSAGE }}
        </div>
      </div>
      
      <div class="THEME_TOGGLE">
        <button @click="toggleTheme" class="THEME_BUTTON">
          <span v-if="IS_DARK_MODE">☀️</span>
          <span v-else>🌙</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SignupPage',
  data() {
    return {
      SIGNUP_FORM: {
        USERNAME: '',
        EMAIL: '',
        PASSWORD: '',
        CONFIRM_PASSWORD: ''
      },
      IS_LOADING: false,
      ERROR_MESSAGE: '',
      CURRENT_LANGUAGE: {
        SIGNUP_SUBTITLE: 'Create your account',
        USERNAME: 'Username',
        USERNAME_PLACEHOLDER: 'Choose a username',
        EMAIL: 'Email',
        EMAIL_PLACEHOLDER: 'Enter your email',
        PASSWORD: 'Password',
        PASSWORD_PLACEHOLDER: 'Choose a password',
        CONFIRM_PASSWORD: 'Confirm Password',
        CONFIRM_PASSWORD_PLACEHOLDER: 'Confirm your password',
        SIGNUP: 'Sign Up',
        LOADING: 'Loading...',
        HAVE_ACCOUNT: 'Already have an account?',
        LOGIN: 'Sign In'
      }
    }
  },
  computed: {
    IS_FORM_VALID() {
      return (
        this.SIGNUP_FORM.USERNAME.trim() !== '' &&
        this.SIGNUP_FORM.EMAIL.trim() !== '' &&
        this.SIGNUP_FORM.PASSWORD.trim() !== '' &&
        this.SIGNUP_FORM.PASSWORD === this.SIGNUP_FORM.CONFIRM_PASSWORD
      )
    },
    IS_DARK_MODE() {
      return this.$root.isDarkMode ? this.$root.isDarkMode() : false
    }
  },
  methods: {
    async REGISTER() {
      if (!this.IS_FORM_VALID) return
      
      this.IS_LOADING = true
      this.ERROR_MESSAGE = ''
      
      try {
        // Register with Supabase Auth
        const { data: authData, error: authError } = await this.$supabase.auth.signUp({
          email: this.SIGNUP_FORM.EMAIL,
          password: this.SIGNUP_FORM.PASSWORD
        })
        
        if (authError) throw authError
        
        // Create user profile in the USERS table
        const { error: profileError } = await this.$supabase
          .from('USERS')
          .insert([{
            ID: authData.user.id,
            USERNAME: this.SIGNUP_FORM.USERNAME,
            DISPLAY_NAME: this.SIGNUP_FORM.USERNAME,
            LANGUAGE: 'en'
          }])
        
        if (profileError) throw profileError
        
        // Redirect to login page with success message
        this.$router.push({
          path: '/login',
          query: { registered: 'true' }
        })
      } catch (error) {
        this.ERROR_MESSAGE = error.message || 'Failed to create account'
      } finally {
        this.IS_LOADING = false
      }
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
.SIGNUP_CONTAINER {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: var(--gradient-bg);
  padding: 20px;
}

.SIGNUP_CARD {
  background-color: var(--card-bg);
  border-radius: 12px;
  box-shadow: var(--card-shadow);
  width: 100%;
  max-width: 450px;
  padding: 40px;
  position: relative;
}

.SIGNUP_HEADER {
  text-align: center;
  margin-bottom: 30px;
}

.SIGNUP_HEADER h1 {
  font-size: 28px;
  font-weight: 700;
  color: var(--accent-primary);
  margin-bottom: 10px;
}

.SIGNUP_HEADER p {
  color: var(--text-secondary);
  font-size: 16px;
}

.FORM_GROUP {
  margin-bottom: 20px;
}

.FORM_GROUP label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: var(--text-primary);
}

.FORM_GROUP input {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid var(--input-border);
  border-radius: 6px;
  font-size: 16px;
  transition: border-color 0.2s, box-shadow 0.2s;
  background-color: var(--input-bg);
  color: var(--text-primary);
}

.FORM_GROUP input:focus {
  border-color: var(--accent-primary);
  outline: none;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.FORM_ACTIONS {
  margin-top: 30px;
}

.FORM_FOOTER {
  margin-top: 20px;
  text-align: center;
  color: var(--text-muted);
}

.FORM_FOOTER a {
  color: var(--accent-primary);
  font-weight: 600;
  text-decoration: none;
}

.ERROR_MESSAGE {
  color: var(--error-color);
  margin-top: 16px;
  padding: 12px;
  background-color: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
  font-size: 14px;
}

.THEME_TOGGLE {
  position: absolute;
  top: 20px;
  right: 20px;
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
  background-color: var(--bg-secondary);
  transition: background-color 0.2s;
}

.THEME_BUTTON:hover {
  background-color: var(--border-color);
}
</style>
