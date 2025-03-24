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
  background: var(--gradient-bg);
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
  background-image: var(--pattern-overlay);
  opacity: 0.6;
  z-index: 0;
}

.LOGIN_CONTAINER::after {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  right: -50%;
  bottom: -50%;
  background: radial-gradient(circle, rgba(59, 130, 246, 0.1) 0%, rgba(59, 130, 246, 0) 70%);
  z-index: 1;
  animation: pulse 15s infinite ease-in-out;
}

@keyframes pulse {
  0% {
    transform: scale(1);
    opacity: 0.5;
  }
  50% {
    transform: scale(1.5);
    opacity: 0.3;
  }
  100% {
    transform: scale(1);
    opacity: 0.5;
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
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
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
  box-shadow: 0 4px 6px rgba(59, 130, 246, 0.2);
  transition: all 0.3s;
  background-image: var(--title-gradient);
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
  box-shadow: 0 6px 8px rgba(59, 130, 246, 0.25);
  background-color: var(--button-hover-bg);
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
