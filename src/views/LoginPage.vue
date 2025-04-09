<template>
  <div class="LOGIN_CONTAINER">
    <div class="LOGIN_CARD">
      <div class="LOGIN_HEADER">
        <div class="LOGO">
          <img src="../assets/logo.png" alt="Bimba Bolao" class="LOGO_IMAGE" />
          <h1>Bimba Bolao</h1>
        </div>
        <p>{{ CURRENT_LANGUAGE.LOGIN_SUBTITLE }}</p>
      </div>
      
      <div class="LOGIN_FORM">
        <div v-if="REGISTRATION_SUCCESS" class="SUCCESS_MESSAGE">
          {{ CURRENT_LANGUAGE.REGISTRATION_SUCCESS }}
        </div>
        <div class="FORM_GROUP">
          <label for="email">{{ CURRENT_LANGUAGE.EMAIL }}</label>
          <div class="INPUT_WRAPPER">
            <input 
              type="email" 
              id="email" 
              v-model="LOGIN_FORM.EMAIL" 
              :placeholder="CURRENT_LANGUAGE.EMAIL_PLACEHOLDER"
            />
          </div>
        </div>
        
        <div class="FORM_GROUP">
          <label for="password">{{ CURRENT_LANGUAGE.PASSWORD }}</label>
          <div class="INPUT_WRAPPER">
            <input 
              type="password" 
              id="password" 
              v-model="LOGIN_FORM.PASSWORD" 
              :placeholder="CURRENT_LANGUAGE.PASSWORD_PLACEHOLDER"
            />
          </div>
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
      REGISTRATION_SUCCESS: false,
      CURRENT_LANGUAGE: {
        LOGIN_TITLE: 'Bimba Bolao',
        LOGIN_SUBTITLE: 'Sign in to your account',
        EMAIL: 'Email',
        EMAIL_PLACEHOLDER: 'Enter your email',
        PASSWORD: 'Password',
        PASSWORD_PLACEHOLDER: 'Enter your password',
        LOGIN: 'Sign In',
        LOADING: 'Loading...',
        NO_ACCOUNT: 'Don\'t have an account?',
        SIGNUP: 'Sign up',
        ERROR_INVALID_CREDENTIALS: 'Invalid email or password',
        ERROR_GENERIC: 'An error occurred. Please try again.',
        REGISTRATION_SUCCESS: 'Registration successful. Please sign in.'
      }
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
        
        if (error) {
          this.ERROR_MESSAGE = error.message === 'Invalid login credentials'
            ? this.CURRENT_LANGUAGE.ERROR_INVALID_CREDENTIALS
            : this.CURRENT_LANGUAGE.ERROR_GENERIC
          return
        }
        
        this.$router.push('/dashboard')
      } catch (error) {
        this.ERROR_MESSAGE = this.CURRENT_LANGUAGE.ERROR_GENERIC
      } finally {
        this.IS_LOADING = false
      }
    }
  },
  mounted() {
    // Check for registration success query parameter
    const query = this.$route.query
    if (query.registered === 'true') {
      this.REGISTRATION_SUCCESS = true
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
  background: var(--bg-primary);
  padding: 20px;
  position: relative;
  overflow: hidden;
}

.LOGIN_CONTAINER::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-size: 20px 20px;
  opacity: 0.03;
  z-index: 0;
  background-image: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm63 31c1.657 0 3-1.343 3-3s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM34 90c1.657 0 3-1.343 3-3s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm56-76c1.657 0 3-1.343 3-3s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.1' fill-rule='evenodd'/%3E%3C/svg%3E");
  animation: pattern-move 120s linear infinite;
}

.LOGIN_CONTAINER::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 30% 40%, rgba(255, 140, 0, 0.05) 0%, rgba(255, 140, 0, 0) 70%),
              radial-gradient(circle at 70% 60%, rgba(255, 140, 0, 0.05) 0%, rgba(255, 140, 0, 0) 70%);
  z-index: 1;
  animation: gradient-pulse 15s infinite ease-in-out;
}

@keyframes pattern-move {
  0% {
    background-position: 0 0;
  }
  100% {
    background-position: 500px 500px;
  }
}

@keyframes gradient-pulse {
  0% {
    opacity: 0.3;
  }
  50% {
    opacity: 0.6;
  }
  100% {
    opacity: 0.3;
  }
}

.LOGIN_CARD {
  background-color: var(--card-bg);
  border-radius: 16px;
  box-shadow: var(--card-shadow);
  width: 100%;
  max-width: 450px;
  padding: 40px;
  position: relative;
  z-index: 10;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: card-appear 0.5s ease-out forwards;
}

.LOGIN_HEADER {
  text-align: center;
  margin-bottom: 36px;
}

.LOGO {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 16px;
}

.LOGO_IMAGE {
  width: 80px;
  height: 80px;
  margin-bottom: 12px;
  object-fit: contain;
  filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
}

.LOGIN_HEADER h1 {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 10px;
  letter-spacing: 0.5px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.LOGIN_HEADER p {
  color: var(--text-secondary);
  font-size: 16px;
}

.FORM_GROUP {
  margin-bottom: 24px;
}

.FORM_GROUP label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: var(--text-primary);
  font-size: 15px;
  transition: all 0.2s;
}

.INPUT_WRAPPER {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.2s;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.FORM_GROUP input {
  width: 100%;
  padding: 14px 16px;
  border: 1px solid var(--input-border);
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.3s;
  background-color: var(--input-bg);
  color: var(--text-primary);
}

.FORM_GROUP input:focus {
  border-color: var(--accent-primary);
  outline: none;
  box-shadow: 0 0 0 3px rgba(255, 140, 0, 0.2);
  transform: translateY(-2px);
}

.FORM_ACTIONS {
  margin-top: 32px;
}

.PRIMARY_BUTTON {
  width: 100%;
  padding: 16px;
  font-size: 16px;
  border-radius: 8px;
  letter-spacing: 0.5px;
  box-shadow: 0 4px 6px rgba(255, 140, 0, 0.2);
  transition: all 0.3s;
  background-color: var(--accent-primary);
  color: var(--button-text);
  position: relative;
  overflow: hidden;
}

.PRIMARY_BUTTON::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: all 0.6s;
}

.PRIMARY_BUTTON:hover:not(:disabled)::before {
  left: 100%;
}

.PRIMARY_BUTTON:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 8px rgba(255, 140, 0, 0.25);
  background-color: var(--accent-secondary);
  color: white;
}

.PRIMARY_BUTTON:active:not(:disabled) {
  transform: translateY(0);
}

.FORM_FOOTER {
  margin-top: 24px;
  text-align: center;
  color: var(--text-muted);
}

.FORM_FOOTER a {
  color: var(--accent-primary);
  font-weight: 600;
  text-decoration: none;
  transition: all 0.2s;
}

.FORM_FOOTER a:hover {
  text-decoration: underline;
}

.ERROR_MESSAGE {
  margin-top: 24px;
  padding: 14px;
  background-color: rgba(239, 68, 68, 0.1);
  border-left: 4px solid var(--error-color);
  border-radius: 6px;
  color: var(--error-color);
  font-size: 14px;
}

.SUCCESS_MESSAGE {
  margin-top: 24px;
  padding: 14px;
  background-color: rgba(34, 197, 94, 0.1);
  border-left: 4px solid var(--success-color);
  border-radius: 6px;
  color: var(--success-color);
  font-size: 14px;
}
</style>
