<template>
  <div class="LOGIN_CONTAINER">
    <div class="LOGIN_CARD">
      <div class="LOGIN_HEADER">
        <h1>Bimba Bolão</h1>
        <p>{{ CURRENT_LANGUAGE.LOGIN_SUBTITLE }}</p>
      </div>
      
      <div class="LOGIN_FORM">
        <div class="FORM_GROUP">
          <label for="email">{{ CURRENT_LANGUAGE.EMAIL }}</label>
          <input 
            type="email" 
            id="email" 
            v-model="LOGIN_FORM.EMAIL" 
            :placeholder="CURRENT_LANGUAGE.EMAIL_PLACEHOLDER"
          />
        </div>
        
        <div class="FORM_GROUP">
          <label for="password">{{ CURRENT_LANGUAGE.PASSWORD }}</label>
          <input 
            type="password" 
            id="password" 
            v-model="LOGIN_FORM.PASSWORD" 
            :placeholder="CURRENT_LANGUAGE.PASSWORD_PLACEHOLDER"
          />
        </div>
        
        <div class="FORM_ACTIONS">
          <button 
            class="PRIMARY_BUTTON" 
            @click="LOGIN"
            :disabled="IS_LOADING"
          >
            <span v-if="IS_LOADING">{{ CURRENT_LANGUAGE.LOADING }}</span>
            <span v-else>{{ CURRENT_LANGUAGE.LOGIN }}</span>
          </button>
        </div>
        
        <div class="FORM_FOOTER">
          <p>
            {{ CURRENT_LANGUAGE.NO_ACCOUNT }} 
            <router-link to="/signup">{{ CURRENT_LANGUAGE.SIGNUP }}</router-link>
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
  name: 'LoginPage',
  data() {
    return {
      LOGIN_FORM: {
        EMAIL: '',
        PASSWORD: ''
      },
      IS_LOADING: false,
      ERROR_MESSAGE: '',
      CURRENT_LANGUAGE: {
        LOGIN_SUBTITLE: 'Sign in to your account',
        EMAIL: 'Email',
        EMAIL_PLACEHOLDER: 'Enter your email',
        PASSWORD: 'Password',
        PASSWORD_PLACEHOLDER: 'Enter your password',
        LOGIN: 'Sign In',
        LOADING: 'Loading...',
        NO_ACCOUNT: 'Don\'t have an account?',
        SIGNUP: 'Sign Up'
      }
    }
  },
  computed: {
    IS_DARK_MODE() {
      return this.$root.isDarkMode ? this.$root.isDarkMode() : false
    }
  },
  methods: {
    async LOGIN() {
      this.IS_LOADING = true
      this.ERROR_MESSAGE = ''
      
      try {
        const { error } = await this.$supabase.auth.signInWithPassword({
          email: this.LOGIN_FORM.EMAIL,
          password: this.LOGIN_FORM.PASSWORD
        })
        
        if (error) throw error
        
        // Redirect to dashboard on successful login
        this.$router.push('/dashboard')
      } catch (error) {
        this.ERROR_MESSAGE = error.message || 'Failed to sign in'
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
.LOGIN_CONTAINER {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: var(--gradient-bg);
  padding: 20px;
}

.LOGIN_CARD {
  background-color: var(--card-bg);
  border-radius: 12px;
  box-shadow: var(--card-shadow);
  width: 100%;
  max-width: 450px;
  padding: 40px;
  position: relative;
}

.LOGIN_HEADER {
  text-align: center;
  margin-bottom: 30px;
}

.LOGIN_HEADER h1 {
  font-size: 28px;
  font-weight: 700;
  color: var(--accent-primary);
  margin-bottom: 10px;
}

.LOGIN_HEADER p {
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

.PRIMARY_BUTTON {
  width: 100%;
  background-color: var(--accent-primary);
  color: white;
  border: none;
  border-radius: 6px;
  padding: 14px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.PRIMARY_BUTTON:hover {
  background-color: var(--accent-secondary);
}

.PRIMARY_BUTTON:disabled {
  background-color: var(--bg-secondary);
  cursor: not-allowed;
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

.FORM_FOOTER a:hover {
  text-decoration: underline;
}

.ERROR_MESSAGE {
  margin-top: 20px;
  padding: 12px;
  background-color: var(--error-bg);
  border: 1px solid var(--error-border);
  border-radius: 6px;
  color: var(--error-text);
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
