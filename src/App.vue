<template>
  <div id="APP" :class="{ 'dark-mode': IS_DARK_MODE }">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      IS_DARK_MODE: localStorage.getItem('DARK_MODE') !== 'false'
    }
  },
  created() {
    // Make dark mode toggle available globally
    this.$root.toggleDarkMode = this.toggleDarkMode
    this.$root.isDarkMode = () => this.IS_DARK_MODE
    
    // Set dark mode as default if not set
    if (localStorage.getItem('DARK_MODE') === null) {
      localStorage.setItem('DARK_MODE', 'true')
    }
  },
  methods: {
    toggleDarkMode() {
      this.IS_DARK_MODE = !this.IS_DARK_MODE
      localStorage.setItem('DARK_MODE', this.IS_DARK_MODE)
    }
  }
}
</script>

<style>
:root {
  /* Light mode colors */
  --bg-primary: #ffffff;
  --bg-secondary: #f3f4f6;
  --text-primary: #1f2937;
  --text-secondary: #4b5563;
  --text-muted: #6b7280;
  --accent-primary: #1e3c72;
  --accent-secondary: #2a5298;
  --border-color: #e5e7eb;
  --card-bg: #ffffff;
  --card-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  --input-bg: #ffffff;
  --input-border: #d1d5db;
  --error-color: #ef4444;
  --success-color: #34c759;
  --gradient-bg: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  --pattern-overlay: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%231e3c72' fill-opacity='0.05' fill-rule='evenodd'/%3E%3C/svg%3E");
}

.dark-mode {
  /* Dark mode colors */
  --bg-primary: #121212;
  --bg-secondary: #1e1e1e;
  --text-primary: #f9fafb;
  --text-secondary: #e5e7eb;
  --text-muted: #9ca3af;
  --accent-primary: #60a5fa;
  --accent-secondary: #93c5fd;
  --border-color: #374151;
  --card-bg: #1e1e1e;
  --card-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
  --input-bg: #272727;
  --input-border: #4b5563;
  --error-color: #f87171;
  --success-color: #22c55e;
  --gradient-bg: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%);
  --pattern-overlay: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%233b82f6' fill-opacity='0.05' fill-rule='evenodd'/%3E%3C/svg%3E");
  --button-text: #ffffff;
  --button-hover-bg: #60a5fa;
  --button-hover-text: #ffffff;
  --title-gradient: linear-gradient(135deg, #93c5fd 0%, #60a5fa 100%);
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  transition: background-color 0.3s, color 0.3s, border-color 0.3s;
}

body {
  font-family: 'Roboto', 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: var(--text-primary);
  line-height: 1.6;
  background-color: var(--bg-primary);
  background-image: var(--pattern-overlay);
}

#APP {
  min-height: 100vh;
  background-color: var(--bg-primary);
  background-image: var(--pattern-overlay);
}

button {
  cursor: pointer;
  font-family: inherit;
}

a {
  text-decoration: none;
  color: var(--accent-primary);
  transition: color 0.2s;
}

a:hover {
  color: var(--accent-secondary);
}

input, button {
  font-size: 16px;
  border-radius: 6px;
}

.PRIMARY_BUTTON {
  background-color: var(--accent-primary);
  color: var(--button-text);
  border: none;
  border-radius: 6px;
  padding: 14px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.PRIMARY_BUTTON:hover {
  background-color: var(--button-hover-bg);
  color: var(--button-hover-text);
}

.PRIMARY_BUTTON:disabled {
  background-color: var(--text-muted);
  cursor: not-allowed;
}

.ERROR_MESSAGE {
  color: var(--error-color);
  margin-top: 16px;
  padding: 12px;
  background-color: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
  font-size: 14px;
}

.SUCCESS_MESSAGE {
  color: var(--success-color);
  margin-top: 16px;
  padding: 12px;
  background-color: rgba(34, 197, 89, 0.1);
  border-radius: 6px;
  font-size: 14px;
}
</style>
