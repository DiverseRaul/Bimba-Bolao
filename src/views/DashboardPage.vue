<template>
  <div>
    <page-loader :isVisible="PAGE_LOADING" />
    <app-header :USER="USER" currentPage="dashboard" />

    <div class="dashboard-container">
      <div class="dashboard-header">
        <h2 class="dashboard-title">Dashboard</h2>
        <div class="actions">
          <button @click="openJoinGroupModal" class="action-btn join-btn">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon">
              <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
              <circle cx="8.5" cy="7" r="4"></circle>
              <line x1="20" y1="8" x2="20" y2="14"></line>
              <line x1="23" y1="11" x2="17" y2="11"></line>
            </svg>
            Join Group
          </button>
          <button @click="openCreateGroupModal" class="action-btn">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            Create Group
          </button>
        </div>
      </div>

      <!-- Groups Section -->
      <div class="dashboard-section groups-section">
        <div class="section-header">
          <h3 class="section-title">Your Groups</h3>
        </div>
        
        <div v-if="IS_LOADING" class="loading">Loading...</div>
        
        <div v-else-if="USER_GROUPS.length === 0" class="empty-state">
          <p>You don't have any groups yet.</p>
          <p>Click the "Create Group" button above to get started.</p>
        </div>
        
        <div v-else class="groups-grid">
          <div 
            v-for="group in USER_GROUPS" 
            :key="group.ID" 
            class="group-card"
            @click="navigateToGroup(group.ID)"
          >
            <h3>{{ group.NAME }}</h3>
            <p v-if="group.DESCRIPTION">{{ group.DESCRIPTION }}</p>
            <div class="group-meta">
              <span class="role">{{ group.ROLE || 'Member' }}</span>
              <span class="created">{{ group.CREATED_AT }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Debug Section -->
      <div class="dashboard-section debug-section" v-if="DEBUG_INFO">
        <div class="section-header">
          <h2>Debug Information</h2>
        </div>
        <div class="debug-content">
          <pre>{{ DEBUG_INFO }}</pre>
        </div>
      </div>
    </div>

    <!-- Create Group Modal -->
    <div class="modal" v-if="SHOW_CREATE_GROUP_MODAL">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Create New Group</h2>
          <button @click="closeModals" class="close-btn">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="group-name">Group Name</label>
            <input 
              type="text" 
              id="group-name" 
              v-model="NEW_GROUP.NAME"
              placeholder="Enter group name"
            >
          </div>
          <div class="form-group">
            <label for="group-description">Description</label>
            <textarea 
              id="group-description" 
              v-model="NEW_GROUP.DESCRIPTION"
              placeholder="Enter group description (optional)"
            ></textarea>
          </div>
          <div v-if="GROUP_ERROR" class="error-message">
            {{ GROUP_ERROR }}
          </div>
          <div v-if="DEBUG_INFO" class="debug-info">
            <h4>Debug Information:</h4>
            <pre>{{ DEBUG_INFO }}</pre>
          </div>
          <div class="form-actions">
            <button 
              @click="createGroup" 
              class="action-btn"
              :disabled="IS_CREATING_GROUP"
            >
              {{ IS_CREATING_GROUP ? 'Creating...' : 'Create Group' }}
            </button>
            <button @click="closeModals" class="cancel-btn">
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Join Group Modal -->
    <div class="modal" v-if="SHOW_JOIN_GROUP_MODAL">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Join Group</h2>
          <button @click="closeModals" class="close-btn">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="invite-code">Invite Code</label>
            <input 
              type="text" 
              id="invite-code" 
              v-model="INVITE_CODE"
              placeholder="Enter invite code"
            >
          </div>
          <div v-if="JOIN_GROUP_ERROR" class="error-message">
            {{ JOIN_GROUP_ERROR }}
          </div>
          <div v-if="DEBUG_INFO" class="debug-info">
            <h4>Debug Information:</h4>
            <pre>{{ DEBUG_INFO }}</pre>
          </div>
          <div class="form-actions">
            <button 
              @click="joinGroup" 
              class="action-btn"
              :disabled="IS_JOINING_GROUP"
            >
              {{ IS_JOINING_GROUP ? 'Joining...' : 'Join Group' }}
            </button>
            <button @click="closeModals" class="cancel-btn">
              Cancel
            </button>
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
  name: 'DashboardPage',
  components: {
    AppHeader,
    PageLoader
  },
  data() {
    return {
      USER: null,
      USER_GROUPS: [],
      IS_LOADING: true,
      PAGE_LOADING: true,
      SHOW_CREATE_GROUP_MODAL: false,
      SHOW_JOIN_GROUP_MODAL: false,
      IS_CREATING_GROUP: false,
      IS_JOINING_GROUP: false,
      GROUP_ERROR: '',
      JOIN_GROUP_ERROR: '',
      DEBUG_INFO: '',
      NEW_GROUP: {
        NAME: '',
        DESCRIPTION: ''
      },
      INVITE_CODE: ''
    }
  },
  mounted() {
    this.applyTheme()
    this.loadUser()
    setTimeout(() => {
      this.PAGE_LOADING = false
    }, 1000)
    this.loadUserGroups()
  },
  methods: {
    async loadUser() {
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        this.USER = user
      } catch (error) {
        console.error('Error loading user:', error)
      }
    },
    async loadUserGroups() {
      this.IS_LOADING = true
      
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        console.log('Loading groups for user ID:', user.id)
        
        try {
          // Get all groups data
          const { data: groupsData, error: groupsError } = await this.$supabase
            .from('groups')
            .select('*')
          
          if (groupsError) {
            console.error('Error loading groups:', groupsError)
            throw groupsError
          }
          
          if (groupsData && groupsData.length > 0) {
            console.log('Found groups:', groupsData.length)
            console.log('Groups data:', JSON.stringify(groupsData))
            
            // Map groups and properly check for admin status
            this.USER_GROUPS = groupsData.map(group => {
              // Check if current user is the admin (exact match)
              const isAdmin = group.admin_id === user.id
              console.log(`Group ${group.id}: admin_id=${group.admin_id}, user.id=${user.id}, isAdmin=${isAdmin}`)
              
              return {
                ID: group.id,
                NAME: group.name,
                DESCRIPTION: group.description,
                ROLE: isAdmin ? 'ADMIN' : 'MEMBER',
                CREATED_AT: new Date(group.created_at).toLocaleDateString()
              }
            })
            
            console.log('Mapped groups:', this.USER_GROUPS.length)
          } else {
            console.log('No groups found')
            this.USER_GROUPS = []
          }
        } catch (error) {
          console.error('Error processing groups:', error)
          this.USER_GROUPS = []
        } finally {
          this.IS_LOADING = false
        }
      } catch (error) {
        console.error('Error in loadUserGroups:', error)
        this.IS_LOADING = false
        this.USER_GROUPS = []
      }
    },
    async testConnection() {
      try {
        // Check if we can access the database
        const { data, error } = await this.$supabase
          .from('groups')
          .select('id')
          .limit(1)
        
        if (error) {
          return {
            success: false,
            message: `Connection failed: ${error.message}`,
            error
          }
        }
        
        return {
          success: true,
          message: 'Connection successful',
          data
        }
      } catch (error) {
        console.error('Connection test error:', error)
        return {
          success: false,
          message: `Connection test error: ${error.message}`,
          error
        }
      }
    },
    navigateToGroup(groupId) {
      console.log('Navigating to group with ID:', groupId)
      this.$router.push(`/group/${groupId}`)
    },
    openCreateGroupModal() {
      this.SHOW_CREATE_GROUP_MODAL = true
      this.GROUP_ERROR = ''
      this.DEBUG_INFO = ''
    },
    openJoinGroupModal() {
      this.SHOW_JOIN_GROUP_MODAL = true
      this.JOIN_GROUP_ERROR = ''
      this.DEBUG_INFO = ''
      this.INVITE_CODE = ''
    },
    closeModals() {
      this.SHOW_CREATE_GROUP_MODAL = false
      this.SHOW_JOIN_GROUP_MODAL = false
      this.GROUP_ERROR = ''
      this.JOIN_GROUP_ERROR = ''
      this.DEBUG_INFO = ''
      this.NEW_GROUP = {
        NAME: '',
        DESCRIPTION: ''
      }
      this.INVITE_CODE = ''
    },
    generateInviteCode() {
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      let code = ''
      for (let i = 0; i < 8; i++) {
        code += characters.charAt(Math.floor(Math.random() * characters.length))
      }
      return code
    },
    async createGroup() {
      if (!this.NEW_GROUP.NAME.trim()) {
        this.GROUP_ERROR = 'Group name is required'
        return
      }
      
      this.IS_CREATING_GROUP = true
      this.GROUP_ERROR = ''
      this.DEBUG_INFO = ''
      
      try {
        const connectionTest = await this.testConnection()
        this.DEBUG_INFO = `Connection test: ${JSON.stringify(connectionTest, null, 2)}\n`
        
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        console.log('Creating group with user ID:', user.id)
        this.DEBUG_INFO += `User ID: ${user.id}\n`
        
        try {
          // Try a simpler approach with minimal fields
          const groupInsert = {
            name: this.NEW_GROUP.NAME,
            admin_id: user.id // Set admin_id directly during creation
          }
          
          // Only add description if it's not empty
          if (this.NEW_GROUP.DESCRIPTION && this.NEW_GROUP.DESCRIPTION.trim()) {
            groupInsert.description = this.NEW_GROUP.DESCRIPTION
          }
          
          this.DEBUG_INFO += `Group Insert Data: ${JSON.stringify(groupInsert, null, 2)}\n`
          
          const { data: groupData, error: groupError } = await this.$supabase
            .from('groups')
            .insert(groupInsert)
            .select()
          
          if (groupError) {
            console.error('Error creating group:', groupError)
            this.DEBUG_INFO += `Group Error: ${JSON.stringify(groupError, null, 2)}\n`
            throw new Error(groupError.message || 'Failed to create group')
          }
          
          if (!groupData || groupData.length === 0) {
            throw new Error('No group data returned after creation')
          }
          
          const newGroup = groupData[0]
          this.DEBUG_INFO += `Group created: ${JSON.stringify(newGroup, null, 2)}\n`
          
          // Group creation was successful, close modals and reload groups
          this.closeModals()
          this.loadUserGroups()
          return
        } catch (standardError) {
          console.error('Standard approach failed:', standardError)
          this.DEBUG_INFO += `Standard approach error: ${JSON.stringify(standardError, null, 2)}\n`
          this.GROUP_ERROR = `Failed to create group: ${standardError.message || 'Database error'}`
        }
      } catch (error) {
        console.error('Error creating group:', error)
        
        if (!error || Object.keys(error).length === 0) {
          this.GROUP_ERROR = 'Failed to create group: Database connection error or insufficient permissions'
          this.DEBUG_INFO += `Empty error object. This usually indicates a connection issue or permission problem.\n`
          this.DEBUG_INFO += `Please check your Supabase connection and RLS policies.\n`
        } else {
          this.GROUP_ERROR = `Failed to create group: ${error.message || 'Unknown error'}`
          this.DEBUG_INFO += `Catch Error: ${JSON.stringify(error, null, 2)}`
        }
      } finally {
        this.IS_CREATING_GROUP = false
      }
    },
    async joinGroup() {
      if (!this.INVITE_CODE.trim()) {
        this.JOIN_GROUP_ERROR = 'Invite code is required'
        return
      }
      
      this.IS_JOINING_GROUP = true
      this.JOIN_GROUP_ERROR = ''
      this.DEBUG_INFO = ''
      
      try {
        const connectionTest = await this.testConnection()
        this.DEBUG_INFO = `Connection test: ${JSON.stringify(connectionTest, null, 2)}\n`
        
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        console.log('Joining group with user ID:', user.id)
        this.DEBUG_INFO += `User ID: ${user.id}\n`
        
        try {
          // Try to find the group by invite code
          const { data: groupData, error: groupError } = await this.$supabase
            .from('groups')
            .select('id, name, description, admin_id')
            .eq('invite_code', this.INVITE_CODE)
          
          if (groupError) {
            console.error('Error finding group:', groupError)
            this.DEBUG_INFO += `Group Error: ${JSON.stringify(groupError, null, 2)}\n`
            throw new Error(groupError.message || 'Failed to find group')
          }
          
          if (!groupData || groupData.length === 0) {
            throw new Error('No group found with the provided invite code')
          }
          
          const group = groupData[0]
          this.DEBUG_INFO += `Group found: ${JSON.stringify(group, null, 2)}\n`
          
          // Check if the user is already a member of the group
          const { data: membershipData, error: membershipError } = await this.$supabase
            .from('group_members')
            .select('id')
            .eq('group_id', group.id)
            .eq('user_id', user.id)
          
          if (membershipError) {
            console.error('Error checking membership:', membershipError)
            this.DEBUG_INFO += `Membership Error: ${JSON.stringify(membershipError, null, 2)}\n`
            throw new Error(membershipError.message || 'Failed to check membership')
          }
          
          if (membershipData && membershipData.length > 0) {
            throw new Error('You are already a member of this group')
          }
          
          // Add the user to the group
          const { data: newMembership, error: newMembershipError } = await this.$supabase
            .from('group_members')
            .insert({
              group_id: group.id,
              user_id: user.id
            })
          
          if (newMembershipError) {
            console.error('Error adding membership:', newMembershipError)
            this.DEBUG_INFO += `New Membership Error: ${JSON.stringify(newMembershipError, null, 2)}\n`
            throw new Error(newMembershipError.message || 'Failed to add membership')
          }
          
          this.DEBUG_INFO += `Membership added: ${JSON.stringify(newMembership, null, 2)}\n`
          
          // Group join was successful, close modals and reload groups
          this.closeModals()
          this.loadUserGroups()
          return
        } catch (standardError) {
          console.error('Standard approach failed:', standardError)
          this.DEBUG_INFO += `Standard approach error: ${JSON.stringify(standardError, null, 2)}\n`
          this.JOIN_GROUP_ERROR = `Failed to join group: ${standardError.message || 'Database error'}`
        }
      } catch (error) {
        console.error('Error joining group:', error)
        
        if (!error || Object.keys(error).length === 0) {
          this.JOIN_GROUP_ERROR = 'Failed to join group: Database connection error or insufficient permissions'
          this.DEBUG_INFO += `Empty error object. This usually indicates a connection issue or permission problem.\n`
          this.DEBUG_INFO += `Please check your Supabase connection and RLS policies.\n`
        } else {
          this.JOIN_GROUP_ERROR = `Failed to join group: ${error.message || 'Unknown error'}`
          this.DEBUG_INFO += `Catch Error: ${JSON.stringify(error, null, 2)}`
        }
      } finally {
        this.IS_JOINING_GROUP = false
      }
    },
    async logout() {
      try {
        await this.$supabase.auth.signOut()
        this.$router.push('/login')
      } catch (error) {
        console.error('Error signing out:', error)
      }
    },
    applyTheme() {
      const theme = localStorage.getItem('theme')
      console.log('Applying theme from localStorage:', theme)
      if (theme === 'light') {
        document.body.classList.add('light-mode')
      } else {
        document.body.classList.remove('light-mode')
      }
    },
  }
}
</script>

<style scoped>
.dashboard-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  color: var(--text-primary);
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.dashboard-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
}

.dashboard-section {
  margin-bottom: 40px;
}

.section-header {
  margin-bottom: 16px;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.groups-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-top: 20px;
}

.group-card {
  background-color: var(--card-bg);
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid var(--border-color);
  height: 100%;
  display: flex;
  flex-direction: column;
  box-shadow: var(--card-shadow);
  position: relative;
  overflow: hidden;
}

.group-card::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--accent-primary);
  opacity: 0;
  transition: opacity 0.2s;
}

.group-card:hover {
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
  transform: translateY(-4px);
}

.group-card:hover::after {
  opacity: 1;
}

.group-card h3 {
  margin: 0 0 10px 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
}

.group-card p {
  margin: 0 0 15px 0;
  font-size: 14px;
  color: var(--text-secondary);
  flex-grow: 1;
}

.group-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--text-muted);
  margin-top: auto;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-secondary);
}

.empty-state p {
  margin-bottom: 20px;
  font-size: 16px;
}

.actions {
  display: flex;
  gap: 10px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background-color: var(--accent-primary);
  color: white;
  border: none;
  border-radius: 50px;
  padding: 12px 20px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.action-btn:hover {
  background-color: var(--accent-secondary);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.action-btn .icon {
  stroke-width: 2.5;
}

.join-btn {
  background-color: var(--accent-secondary);
}

.join-btn:hover {
  background-color: var(--accent-primary);
}

.loading {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-secondary);
  font-size: 16px;
}

/* Modal */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background-color: var(--card-bg);
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--card-shadow);
  border: 1px solid var(--border-color);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid var(--border-color);
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  color: var(--text-primary);
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--text-secondary);
  transition: color 0.2s;
}

.close-btn:hover {
  color: var(--text-primary);
}

.modal-body {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: var(--text-primary);
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid var(--input-border);
  border-radius: 4px;
  background-color: var(--input-bg);
  color: var(--text-primary);
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group textarea:focus {
  border-color: var(--accent-primary);
  outline: none;
}

.form-group textarea {
  min-height: 100px;
  resize: vertical;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn {
  background-color: transparent;
  border: 1px solid var(--input-border);
  color: var(--text-primary);
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.cancel-btn:hover {
  background-color: rgba(255, 255, 255, 0.05);
}

.error-message {
  color: var(--error-color);
  margin-bottom: 15px;
  padding: 8px;
  background-color: rgba(239, 68, 68, 0.1);
  border-radius: 4px;
}

.debug-info {
  margin-top: 20px;
  padding: 10px;
  background-color: var(--bg-secondary);
  border-radius: 4px;
  font-size: 12px;
  border: 1px solid var(--border-color);
}

.debug-info pre {
  white-space: pre-wrap;
  word-break: break-word;
  max-height: 200px;
  overflow-y: auto;
  color: var(--accent-primary);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .dashboard-content {
    grid-template-columns: 1fr;
  }
  
  .groups-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }
}
</style>
