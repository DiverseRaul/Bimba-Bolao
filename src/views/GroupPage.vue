<template>
  <div class="GROUP_CONTAINER">
    <page-loader :isVisible="PAGE_LOADING" />
    <app-header :USER="USER" @logout="logout" currentPage="group" />
    
    <main class="GROUP_CONTENT">
      <div v-if="IS_LOADING" class="LOADING_CONTAINER">
        <div class="LOADING_SPINNER"></div>
        <p>{{ CURRENT_LANGUAGE.LOADING }}</p>
      </div>
      
      <div v-else-if="GROUP_DATA" class="GROUP_DETAILS">
        <div class="GROUP_HEADER">
          <h1 class="GROUP_TITLE">{{ GROUP_DATA.NAME }}</h1>
          <div class="HEADER_ACTIONS">
            <button v-if="IS_ADMIN" class="ACTION_BUTTON" @click="showInviteModal">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
              </svg>
              {{ CURRENT_LANGUAGE.INVITE }}
            </button>
            <div v-if="!IS_ADMIN" class="ADMIN_DEBUG">
              <small style="color: red;">Admin status: {{ IS_ADMIN ? 'Yes' : 'No' }}</small>
            </div>
          </div>
        </div>
        
        <div class="GROUP_INFO_CARD">
          <div class="GROUP_INFO_HEADER">
            <h2>{{ CURRENT_LANGUAGE.GROUP_INFO }}</h2>
            <span class="MEMBER_COUNT">{{ MEMBERS.length }} {{ CURRENT_LANGUAGE.MEMBERS }}</span>
          </div>
          <p class="GROUP_DESCRIPTION">{{ GROUP_DATA.DESCRIPTION || CURRENT_LANGUAGE.NO_DESCRIPTION }}</p>
          
          <div class="MEMBERS_LIST">
            <h3>{{ CURRENT_LANGUAGE.MEMBERS }}</h3>
            <div class="MEMBER_ITEM" v-for="member in MEMBERS" :key="member.ID">
              <div class="MEMBER_NAME">{{ member.NAME }}</div>
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
          <div v-if="IS_GENERATING_CODE" class="LOADING_CONTAINER">
            <div class="LOADING_SPINNER"></div>
            <p>{{ CURRENT_LANGUAGE.GENERATING_CODE }}</p>
          </div>
          
          <div v-else class="INVITE_CODE_SECTION">
            <h4>{{ CURRENT_LANGUAGE.INVITATION_CODE }}</h4>
            <div class="INVITE_CODE_DISPLAY">
              <span class="INVITE_CODE">{{ INVITE_CODE || 'Generating...' }}</span>
              <button class="COPY_BUTTON" @click="copyInviteCode" :disabled="!INVITE_CODE">
                {{ COPIED ? CURRENT_LANGUAGE.COPIED : CURRENT_LANGUAGE.COPY }}
              </button>
            </div>
            
            <p class="INVITE_INSTRUCTIONS">{{ CURRENT_LANGUAGE.INVITE_INSTRUCTIONS }}</p>
            
            <div class="INVITE_ACTIONS">
              <button 
                v-if="!INVITE_CODE" 
                class="GENERATE_BUTTON" 
                @click="generateAndSaveInviteCode"
                :disabled="IS_GENERATING_CODE"
              >
                {{ CURRENT_LANGUAGE.GENERATE_CODE }}
              </button>
              
              <button 
                v-else 
                class="REGENERATE_BUTTON" 
                @click="generateAndSaveInviteCode"
                :disabled="IS_GENERATING_CODE"
              >
                {{ CURRENT_LANGUAGE.REGENERATE_CODE }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader.vue';
import PageLoader from '@/components/PageLoader.vue';

export default {
  name: 'GroupPage',
  components: {
    AppHeader,
    PageLoader
  },
  data() {
    return {
      USER: null,
      GROUP_ID: null,
      GROUP_DATA: null,
      MEMBERS: [],
      IS_ADMIN: false,
      IS_LOADING: true,
      PAGE_LOADING: true,
      SHOW_INVITE_MODAL: false,
      INVITE_CODE: '',
      COPIED: false,
      IS_GENERATING_CODE: false,
      CURRENT_LANGUAGE: {
        LOADING: 'Loading group data...',
        GROUP_INFO: 'Group Information',
        GROUP_NOT_FOUND: 'Group not found or you do not have access.',
        BACK_TO_DASHBOARD: 'Back to Dashboard',
        MEMBERS: 'Members',
        NO_DESCRIPTION: 'No description provided.',
        PREDICTIONS: 'Predictions',
        PREDICTIONS_COMING_SOON: 'Predictions feature coming soon!',
        INVITE: 'Invite',
        INVITE_MEMBERS: 'Invite Members',
        INVITATION_CODE: 'Share this code with friends',
        COPY: 'Copy',
        COPIED: 'Copied!',
        INVITE_INSTRUCTIONS: 'Your friends can use this code to join your group from the dashboard.',
        GENERATING_CODE: 'Generating code...',
        GENERATE_CODE: 'Generate Code',
        REGENERATE_CODE: 'Regenerate Code'
      }
    }
  },
  mounted() {
    this.applyTheme()
    // Get the group ID from route params
    this.GROUP_ID = this.$route.params.id
    console.log('Group ID from route:', this.GROUP_ID)
    
    // Ensure we have a valid group ID before loading
    if (this.GROUP_ID) {
      this.loadGroupData()
    } else {
      console.error('No group ID provided in route')
      this.IS_LOADING = false
      this.GROUP_DATA = null
    }
    
    setTimeout(() => {
      this.PAGE_LOADING = false
    }, 1000)
  },
  methods: {
    applyTheme() {
      const theme = localStorage.getItem('theme')
      console.log('Applying theme from localStorage:', theme)
      if (theme === 'light') {
        document.body.classList.add('light-mode')
      } else {
        document.body.classList.remove('light-mode')
      }
    },
    navigateToDashboard() {
      this.$router.push('/dashboard')
    },
    
    async loadGroupData() {
      this.IS_LOADING = true
      
      try {
        // First get the user data
        const { data: { user }, error: userError } = await this.$supabase.auth.getUser();
        
        if (userError) {
          console.error('Error fetching user:', userError);
          this.IS_LOADING = false;
          return;
        }
        
        if (!user) {
          console.log('No authenticated user found, redirecting to login.');
          this.$router.push('/login');
          return;
        }
        
        // Store user data
        this.USER = user;
        
        console.log('Loading group with ID:', this.GROUP_ID);
        console.log('Current user ID:', user.id);
        
        // Get group data first - IMPORTANT: use lowercase field names for Supabase
        const { data: groupData, error: groupError } = await this.$supabase
          .from('groups')
          .select('*')
          .eq('id', this.GROUP_ID)
          .single()
        
        if (groupError) {
          console.error('Error fetching group:', groupError);
          this.GROUP_DATA = null;
          this.IS_LOADING = false;
          return;
        }
        
        if (!groupData) {
          console.error('Group not found');
          this.GROUP_DATA = null;
          this.IS_LOADING = false;
          return;
        }
        
        console.log('Found group data:', groupData);
        console.log('Group admin_id:', groupData.admin_id);
        console.log('User ID for comparison:', user.id);
        console.log('Are they equal?', groupData.admin_id === user.id);
        
        // Force admin status to true for testing
        this.IS_ADMIN = true; // Temporarily force admin status to true
        console.log('FORCING IS_ADMIN to TRUE for testing');
        
        // Always show the group data since we found it
        this.GROUP_DATA = {
          ID: groupData.id,
          NAME: groupData.name,
          DESCRIPTION: groupData.description,
          CREATED_AT: groupData.created_at,
          INVITE_CODE: groupData.invite_code
        };
        
        // Set invite code
        this.INVITE_CODE = groupData.invite_code;
        
        // Reset members list
        this.MEMBERS = [];
        
        // Add the admin to members list
        this.MEMBERS.push({
          ID: 'admin',
          ROLE: 'ADMIN',
          USER_ID: groupData.admin_id,
          EMAIL: 'Admin User',
          NAME: 'Group Admin'
        });
        
        // Try to get additional members if the table exists
        try {
          const { data: members, error: membersError } = await this.$supabase
            .from('group_members')
            .select('*')
            .eq('group_id', this.GROUP_ID)
          
          if (!membersError && members && members.length > 0) {
            console.log('Found members:', members);
            
            // Add other members with simplified names
            for (const member of members) {
              this.MEMBERS.push({
                ID: member.id,
                ROLE: 'MEMBER',
                USER_ID: member.user_id,
                EMAIL: 'Member',
                NAME: 'Member ' + member.id.substring(0, 4)
              });
            }
          }
        } catch (memberError) {
          console.error('Error fetching members:', memberError);
        }
        
      } catch (error) {
        console.error('Error loading group data:', error);
        this.GROUP_DATA = null;
      } finally {
        this.IS_LOADING = false;
      }
    },
    
    generateInviteCode() {
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      let code = '';
      for (let i = 0; i < 8; i++) {
        code += characters.charAt(Math.floor(Math.random() * characters.length));
      }
      return code;
    },
    
    showInviteModal() {
      this.SHOW_INVITE_MODAL = true
      this.COPIED = false
      this.INVITE_CODE = ''
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
    },
    
    async generateAndSaveInviteCode() {
      this.IS_GENERATING_CODE = true
      this.INVITE_CODE = this.generateInviteCode()
      // Save the invite code to the database
      try {
        const { error } = await this.$supabase
          .from('groups')
          .update({
            invite_code: this.INVITE_CODE
          })
          .eq('id', this.GROUP_ID)
        
        if (error) {
          console.error('Error saving invite code:', error)
        }
      } catch (error) {
        console.error('Error saving invite code:', error)
      } finally {
        this.IS_GENERATING_CODE = false
      }
    },
    
    logout() {
      this.$supabase.auth.signOut().then(() => {
        this.$router.push('/login');
      });
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

.INVITE_ACTIONS {
  margin-top: 24px;
  display: flex;
  gap: 12px;
}

.GENERATE_BUTTON, .REGENERATE_BUTTON {
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

.GENERATE_BUTTON:hover, .REGENERATE_BUTTON:hover {
  background-color: var(--button-hover-bg);
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(59, 130, 246, 0.3);
}

.GROUP_HEADER {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  background-color: var(--card-bg);
  border-radius: 16px;
  padding: 24px;
  box-shadow: var(--card-shadow);
  border: 1px solid var(--border-color);
}

.GROUP_TITLE {
  font-size: 28px;
  font-weight: 700;
  margin: 0;
  color: var(--text-primary);
}

.HEADER_ACTIONS {
  display: flex;
  gap: 12px;
}

.ACTION_BUTTON {
  display: flex;
  align-items: center;
  gap: 8px;
  background-color: var(--accent-primary);
  color: white;
  border: none;
  border-radius: 50px;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.ACTION_BUTTON:hover {
  background-color: var(--accent-secondary);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.ACTION_BUTTON svg {
  stroke-width: 2;
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
