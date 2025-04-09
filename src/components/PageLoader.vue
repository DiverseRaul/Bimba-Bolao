<template>
  <div class="page-loader" :class="{ 'fade-out': !isVisible }">
    <div class="loader-content">
      <div class="spinner"></div>
      <h2 class="loading-text">Bimba Bolao</h2>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PageLoader',
  props: {
    isVisible: {
      type: Boolean,
      default: true
    }
  }
}
</script>

<style scoped>
.page-loader {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: var(--bg-primary);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  transition: opacity 0.5s ease-out, visibility 0.5s ease-out;
  opacity: 1;
  visibility: visible;
}

.page-loader.fade-out {
  opacity: 0;
  visibility: hidden;
}

.loader-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.spinner {
  width: 60px;
  height: 60px;
  border: 4px solid rgba(255, 140, 0, 0.1);
  border-radius: 50%;
  border-top-color: var(--accent-primary);
  animation: spin 1s ease-in-out infinite;
}

.loading-text {
  font-size: 24px;
  font-weight: 700;
  color: white;
  letter-spacing: 0.5px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}
</style>
