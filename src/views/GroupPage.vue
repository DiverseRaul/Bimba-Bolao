<template>
  <div class="GROUP_CONTAINER">
    <header class="GROUP_HEADER">
      <div class="HEADER_ACTIONS">
        <button class="BACK_BUTTON" @click="navigateToDashboard">
          ← {{ CURRENT_LANGUAGE.BACK }}
        </button>
      </div>
      <div class="GROUP_TITLE" v-if="GROUP_DATA">
        <h1>{{ GROUP_DATA.NAME }}</h1>
      </div>
      <div class="HEADER_ACTIONS">
        <button class="INVITE_BUTTON" @click="showInviteModal" v-if="IS_ADMIN">
          {{ CURRENT_LANGUAGE.INVITE }}
        </button>
      </div>
    </header>
    
    <main class="GROUP_CONTENT">
      <div v-if="IS_LOADING" class="LOADING_CONTAINER">
        <div class="LOADING_SPINNER"></div>
        <p>{{ CURRENT_LANGUAGE.LOADING }}</p>
      </div>
      
      <div v-else-if="GROUP_DATA" class="GROUP_DETAILS">
        <div class="GROUP_INFO_CARD">
          <div class="GROUP_INFO_HEADER">
            <h2>{{ CURRENT_LANGUAGE.GROUP_INFO }}</h2>
            <span class="MEMBER_COUNT">{{ MEMBERS.length }} {{ CURRENT_LANGUAGE.MEMBERS }}</span>
          </div>
          <p class="GROUP_DESCRIPTION">{{ GROUP_DATA.DESCRIPTION || CURRENT_LANGUAGE.NO_DESCRIPTION }}</p>
          
          <div class="MEMBERS_LIST">
            <h3>{{ CURRENT_LANGUAGE.MEMBERS }}</h3>
            <div class="MEMBER_ITEM" v-for="member in MEMBERS" :key="member.ID">
              <div class="MEMBER_NAME">{{ member.NAME || member.EMAIL }}</div>
              <div class="MEMBER_ROLE">{{ member.ROLE }}</div>
            </div>
          </div>
        </div>
        
        <div class="PREDICTIONS_SECTION">
          <h2>{{ CURRENT_LANGUAGE.PREDICTIONS }}</h2>
          <p>{{ CURRENT_LANGUAGE.PREDICTIONS_COMING_SOON }}</p>
        </div>
      </div>
      
      <div v-else class="ERROR_CONTAINER">
        <p>{{ CURRENT_LANGUAGE.GROUP_NOT_FOUND }}</p>
        <button class="PRIMARY_BUTTON" @click="navigateToDashboard">
          {{ CURRENT_LANGUAGE.BACK_TO_DASHBOARD }}
        </button>
      </div>
    </main>
    
    <!-- Invite Modal -->
    <div class="MODAL_OVERLAY" v-if="SHOW_INVITE_MODAL" @click="closeModals">
      <div class="MODAL_CONTENT" @click.stop>
        <div class="MODAL_HEADER">
          <h3>{{ CURRENT_LANGUAGE.INVITE_MEMBERS }}</h3>
          <button class="CLOSE_BUTTON" @click="closeModals">×</button>
        </div>
        <div class="MODAL_BODY">
          <div class="INVITE_CODE_SECTION">
            <h4>{{ CURRENT_LANGUAGE.INVITATION_CODE }}</h4>
            <div class="INVITE_CODE_DISPLAY">
              <span class="INVITE_CODE">{{ INVITE_CODE }}</span>
              <button class="COPY_BUTTON" @click="copyInviteCode">
                {{ COPIED ? CURRENT_LANGUAGE.COPIED : CURRENT_LANGUAGE.COPY }}
              </button>
            </div>
            <p class="INVITE_INSTRUCTIONS">{{ CURRENT_LANGUAGE.INVITE_INSTRUCTIONS }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GroupPage',
  data() {
    return {
      GROUP_ID: null,
      GROUP_DATA: null,
      MEMBERS: [],
      IS_LOADING: true,
      IS_ADMIN: false,
      SHOW_INVITE_MODAL: false,
      INVITE_CODE: '',
      COPIED: false,
      CURRENT_LANGUAGE: {
        BACK: 'Back',
        INVITE: 'Invite',
        LOADING: 'Loading group data...',
        GROUP_INFO: 'Group Information',
        MEMBERS: 'Members',
        NO_DESCRIPTION: 'No description provided',
        PREDICTIONS: 'Predictions',
        PREDICTIONS_COMING_SOON: 'Match predictions will be available soon!',
        GROUP_NOT_FOUND: 'Group not found or you do not have access.',
        BACK_TO_DASHBOARD: 'Back to Dashboard',
        INVITE_MEMBERS: 'Invite Members',
        INVITATION_CODE: 'Share this code with friends',
        COPY: 'Copy',
        COPIED: 'Copied!',
        INVITE_INSTRUCTIONS: 'Your friends can use this code to join your group from the dashboard.'
      }
    }
  },
  mounted() {
    this.applyTheme()
    this.GROUP_ID = this.$route.params.id
    this.loadGroupData()
  },
  methods: {
    applyTheme() {
      const theme = localStorage.getItem('theme')
      if (theme === 'light') {
        document.body.classList.add('light-mode')
        document.body.classList.remove('dark-mode')
      } else {
        document.body.classList.remove('light-mode')
        document.body.classList.add('dark-mode')
      }
    },
    navigateToDashboard() {
      this.$router.push('/dashboard')
    },
    async loadGroupData() {
      this.IS_LOADING = true
      
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        // Check if user is a member of this group
        const { data: memberData, error: memberError } = await this.$supabase
          .from('GROUP_MEMBERS')
          .select('ID, ROLE')
          .eq('GROUP_ID', this.GROUP_ID)
          .eq('USER_ID', user.id)
          .single()
        
        if (memberError || !memberData) {
          this.GROUP_DATA = null
          this.IS_LOADING = false
          return
        }
        
        // User is a member, check if admin
        this.IS_ADMIN = memberData.ROLE === 'ADMIN'
        
        // Get group data
        const { data: groupData, error: groupError } = await this.$supabase
          .from('GROUPS')
          .select('*')
          .eq('ID', this.GROUP_ID)
          .single()
        
        if (groupError) throw groupError
        
        this.GROUP_DATA = groupData
        
        // Get group members
        const { data: members, error: membersError } = await this.$supabase
          .from('GROUP_MEMBERS')
          .select(`
            ID,
            ROLE,
            USER_ID,
            USERS:USER_ID (
              EMAIL,
              NAME
            )
          `)
          .eq('GROUP_ID', this.GROUP_ID)
        
        if (membersError) throw membersError
        
        this.MEMBERS = members.map(member => ({
          ID: member.ID,
          ROLE: member.ROLE,
          USER_ID: member.USER_ID,
          EMAIL: member.USERS.EMAIL,
          NAME: member.USERS.NAME
        }))
        
        // If admin, get invite code
        if (this.IS_ADMIN) {
          const { data: inviteData, error: inviteError } = await this.$supabase
            .from('GROUP_INVITES')
            .select('CODE')
            .eq('GROUP_ID', this.GROUP_ID)
            .order('CREATED_AT', { ascending: false })
            .limit(1)
            .single()
          
          if (!inviteError && inviteData) {
            this.INVITE_CODE = inviteData.CODE
          }
        }
      } catch (error) {
        console.error('Error loading group data:', error)
      } finally {
        this.IS_LOADING = false
      }
    },
    showInviteModal() {
      this.SHOW_INVITE_MODAL = true
      this.COPIED = false
    },
    closeModals() {
      this.SHOW_INVITE_MODAL = false
    },
    copyInviteCode() {
      navigator.clipboard.writeText(this.INVITE_CODE)
      this.COPIED = true
      
      setTimeout(() => {
        this.COPIED = false
      }, 2000)
    }
  }
}
</script>

<style scoped>
.GROUP_CONTAINER {
  min-height: 100vh;
  background-color: var(--bg-primary);
  background-image: var(--pattern-overlay);
}

.GROUP_HEADER {
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

.GROUP_TITLE h1 {
  font-size: 24px;
  font-weight: 700;
  margin: 0;
  letter-spacing: 0.5px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.BACK_BUTTON, .INVITE_BUTTON {
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

.BACK_BUTTON:hover, .INVITE_BUTTON:hover {
  background-color: rgba(255, 255, 255, 0.05);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.GROUP_CONTENT {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px;
}

.LOADING_CONTAINER {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.LOADING_SPINNER {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  border-top-color: var(--accent-primary);
  animation: spin 1s ease-in-out infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.ERROR_CONTAINER {
  text-align: center;
  padding: 40px;
}

.GROUP_INFO_CARD {
  background-color: var(--card-bg);
  border-radius: 16px;
  box-shadow: var(--card-shadow);
  padding: 30px;
  margin-bottom: 32px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: card-appear 0.5s ease-out forwards;
}

.GROUP_INFO_HEADER {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.GROUP_INFO_HEADER h2 {
  font-size: 20px;
  margin: 0;
  font-weight: 600;
}

.MEMBER_COUNT {
  font-size: 14px;
  color: var(--text-secondary);
  background-color: rgba(255, 255, 255, 0.1);
  padding: 6px 12px;
  border-radius: 12px;
}

.GROUP_DESCRIPTION {
  font-size: 16px;
  color: var(--text-secondary);
  line-height: 1.6;
  margin-bottom: 24px;
}

.MEMBERS_LIST {
  margin-top: 24px;
}

.MEMBERS_LIST h3 {
  font-size: 18px;
  margin-bottom: 16px;
  font-weight: 600;
}

.MEMBER_ITEM {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.MEMBER_ITEM:last-child {
  border-bottom: none;
}

.MEMBER_NAME {
  font-size: 15px;
  font-weight: 500;
}

.MEMBER_ROLE {
  font-size: 13px;
  color: var(--text-secondary);
  background-color: rgba(255, 255, 255, 0.1);
  padding: 4px 8px;
  border-radius: 8px;
}

.PREDICTIONS_SECTION {
  background-color: var(--card-bg);
  border-radius: 16px;
  box-shadow: var(--card-shadow);
  padding: 30px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: card-appear 0.5s ease-out forwards;
}

.PREDICTIONS_SECTION h2 {
  font-size: 20px;
  margin-bottom: 16px;
  font-weight: 600;
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
  margin-top: 16px;
}

.PRIMARY_BUTTON:hover {
  background-color: var(--button-hover-bg);
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(59, 130, 246, 0.3);
}

/* Modal Styles */
.MODAL_OVERLAY {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.MODAL_CONTENT {
  background-color: var(--card-bg);
  border-radius: 16px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  animation: modal-appear 0.3s ease-out forwards;
}

@keyframes modal-appear {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

.MODAL_HEADER {
  padding: 20px 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.MODAL_HEADER h3 {
  font-size: 20px;
  font-weight: 600;
  margin: 0;
  color: var(--text-primary);
}

.CLOSE_BUTTON {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  font-size: 24px;
  cursor: pointer;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s;
}

.CLOSE_BUTTON:hover {
  background-color: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
}

.MODAL_BODY {
  padding: 24px;
}

.INVITE_CODE_SECTION h4 {
  font-size: 16px;
  margin-bottom: 12px;
  color: var(--text-secondary);
}

.INVITE_CODE_DISPLAY {
  display: flex;
  align-items: center;
  background-color: var(--input-bg);
  border: 1px solid var(--input-border);
  border-radius: 8px;
  padding: 4px;
  margin-bottom: 16px;
}

.INVITE_CODE {
  flex: 1;
  padding: 12px;
  font-family: monospace;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 1px;
  color: var(--accent-primary);
}

.COPY_BUTTON {
  background-color: var(--accent-primary);
  color: white;
  border: none;
  border-radius: 6px;
  padding: 10px 16px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.COPY_BUTTON:hover {
  background-color: var(--button-hover-bg);
}

.INVITE_INSTRUCTIONS {
  font-size: 14px;
  color: var(--text-secondary);
  line-height: 1.5;
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

@media (max-width: 768px) {
  .GROUP_HEADER {
    flex-direction: column;
    gap: 12px;
    padding: 16px;
  }
  
  .HEADER_ACTIONS {
    width: 100%;
    display: flex;
    justify-content: space-between;
  }
}
</style>
