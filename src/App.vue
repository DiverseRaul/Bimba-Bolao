<template>
  <div id="APP">
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
  watch: {
    IS_DARK_MODE: {
      handler(isDark) {
        this.applyBodyClass(isDark);
      },
      immediate: true
    }
  },
  created() {
    this.$root.toggleDarkMode = this.toggleDarkMode
    this.$root.isDarkMode = () => this.IS_DARK_MODE
  },
  methods: {
    toggleDarkMode() {
      this.IS_DARK_MODE = !this.IS_DARK_MODE
      localStorage.setItem('DARK_MODE', String(this.IS_DARK_MODE))
    },
    applyBodyClass(isDark) {
      const body = document.body;
      if (isDark) {
        body.classList.add('dark-mode');
        body.classList.remove('light-mode');
      } else {
        body.classList.remove('dark-mode');
        body.classList.add('light-mode');
      }
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
  --accent-primary: #ff8c00;
  --accent-secondary: #ff9e2c;
  --border-color: #e5e7eb;
  --card-bg: #ffffff;
  --card-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  --input-bg: #ffffff;
  --input-border: #d1d5db;
  --error-color: #ef4444;
  --success-color: #34c759;
  --gradient-bg: linear-gradient(135deg, #ff8c00 0%, #ff9e2c 100%);
  --pattern-overlay: none;
  --button-text: #ffffff;
  --button-hover-bg: #ff9e2c;
  --button-hover-text: #ffffff;
  --title-gradient: linear-gradient(135deg, #ff8c00 0%, #ff9e2c 100%);
  --header-bg: #121212;
}

.dark-mode {
  /* Dark mode colors */
  --bg-primary: #121212;
  --bg-secondary: #1e1e1e;
  --text-primary: #f9fafb;
  --text-secondary: #e5e7eb;
  --text-muted: #9ca3af;
  --accent-primary: #ff8c00;
  --accent-secondary: #ff9e2c;
  --border-color: #374151;
  --card-bg: #1e1e1e;
  --card-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
  --input-bg: #272727;
  --input-border: #4b5563;
  --error-color: #f87171;
  --success-color: #22c55e;
  --gradient-bg: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%);
  --pattern-overlay: none;
  --button-text: #ffffff;
  --button-hover-bg: #ff9e2c;
  --button-hover-text: #ffffff;
  --title-gradient: linear-gradient(135deg, #ff8c00 0%, #ff9e2c 100%);
  --header-bg: #121212;
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
  transition: background-color 0.3s, color 0.3s;
}

#APP {
  min-height: 100vh;
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
