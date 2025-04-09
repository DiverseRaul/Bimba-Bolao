<template>
  <div class="SIGNUP_CONTAINER">
    <div class="SIGNUP_CARD">
      <div class="SIGNUP_HEADER">
        <div class="LOGO">
          <img src="../assets/logo.png" alt="Bimba Bolao" class="LOGO_IMAGE" />
          <h1>Bimba Bolao</h1>
        </div>
        <p>{{ CURRENT_LANGUAGE.SIGNUP_SUBTITLE }}</p>
      </div>
      
      <div class="SIGNUP_FORM">
        <div class="FORM_GROUP">
          <label for="username">{{ CURRENT_LANGUAGE.USERNAME }}</label>
          <div class="INPUT_WRAPPER">
            <input 
              type="text" 
              id="username" 
              v-model="SIGNUP_FORM.USERNAME" 
              :placeholder="CURRENT_LANGUAGE.USERNAME_PLACEHOLDER"
            />
          </div>
        </div>
        
        <div class="FORM_GROUP">
          <label for="email">{{ CURRENT_LANGUAGE.EMAIL }}</label>
          <div class="INPUT_WRAPPER">
            <input 
              type="email" 
              id="email" 
              v-model="SIGNUP_FORM.EMAIL" 
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
              v-model="SIGNUP_FORM.PASSWORD" 
              :placeholder="CURRENT_LANGUAGE.PASSWORD_PLACEHOLDER"
            />
          </div>
        </div>
        
        <div class="FORM_GROUP">
          <label for="confirmPassword">{{ CURRENT_LANGUAGE.CONFIRM_PASSWORD }}</label>
          <div class="INPUT_WRAPPER">
            <input 
              type="password" 
              id="confirmPassword" 
              v-model="SIGNUP_FORM.CONFIRM_PASSWORD" 
              :placeholder="CURRENT_LANGUAGE.CONFIRM_PASSWORD_PLACEHOLDER"
            />
          </div>
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
        
        if (!authData || !authData.user) {
          throw new Error('User registration successful. Please check your email for confirmation.')
        }
        
        try {
          // Create user profile in the USERS table
          const { error: profileError } = await this.$supabase
            .from('USERS')
            .insert([{
              ID: authData.user.id,
              USERNAME: this.SIGNUP_FORM.USERNAME,
              DISPLAY_NAME: this.SIGNUP_FORM.USERNAME,
              LANGUAGE: 'en'
            }])
          
          if (profileError) {
            console.error('Profile creation error:', profileError)
            // Continue even if profile creation fails - we can handle this later
          }
        } catch (profileCreationError) {
          console.error('Error creating profile:', profileCreationError)
          // Continue even if profile creation fails - we can handle this later
        }
        
        // Redirect to login page with success message
        this.$router.push({
          path: '/login',
          query: { registered: 'true' }
        })
      } catch (error) {
        console.error('Registration error:', error)
        
        // Check if this is actually a success message from email confirmation
        if (error.message && error.message.includes('confirmation')) {
          // This is actually a success case for email confirmation
          this.$router.push({
            path: '/login',
            query: { registered: 'true', confirmation: 'sent' }
          })
          return
        }
        
        this.ERROR_MESSAGE = error.message || 'Failed to create account'
      } finally {
        this.IS_LOADING = false
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
  background: var(--bg-primary);
  padding: 20px;
  position: relative;
  overflow: hidden;
}

.SIGNUP_CONTAINER::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-size: 20px 20px;
  opacity: 0.03;
  z-index: 0;
  background-image: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.1' fill-rule='evenodd'/%3E%3C/svg%3E");
  animation: pattern-move 120s linear infinite;
}

.SIGNUP_CONTAINER::after {
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

.SIGNUP_CARD {
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

.SIGNUP_HEADER {
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

.SIGNUP_HEADER h1 {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 10px;
  letter-spacing: 0.5px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.SIGNUP_HEADER p {
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
</style>
