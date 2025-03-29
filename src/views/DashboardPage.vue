<template>
  <div class="DASHBOARD_CONTAINER">
    <header class="DASHBOARD_HEADER">
      <div class="HEADER_LOGO">
        <img src="../assets/logo.png" alt="Bimba Bolao" class="LOGO_IMAGE" />
        <h1>Bimba Bolao</h1>
      </div>
      <div class="HEADER_ACTIONS">
        <button class="PROFILE_BUTTON" @click="navigateToProfile">
          {{ CURRENT_LANGUAGE.SETTINGS }}
        </button>
      </div>
    </header>
    
    <main class="DASHBOARD_CONTENT">
      <div class="DASHBOARD_WELCOME">
        <h2>{{ CURRENT_LANGUAGE.WELCOME }}</h2>
        <p>{{ CURRENT_LANGUAGE.DASHBOARD_MESSAGE }}</p>
      </div>
      
      <!-- Match Templates Section -->
      <div class="MATCHES_SECTION">
        <h3>{{ CURRENT_LANGUAGE.UPCOMING_MATCHES }}</h3>
        <div class="MATCHES_GRID">
          <!-- Match Card 1 -->
          <div class="MATCH_CARD">
            <div class="MATCH_HEADER">
              <span class="MATCH_TIME">{{ CURRENT_LANGUAGE.TODAY }} • 20:00</span>
              <span class="MATCH_STATUS">{{ CURRENT_LANGUAGE.TIME_LEFT }}: 2h 30min</span>
            </div>
            <div class="MATCH_TEAMS">
              <div class="TEAM">
                <img src="https://via.placeholder.com/40" alt="Team 1" class="TEAM_LOGO" />
                <span class="TEAM_NAME">Brazil</span>
              </div>
              <div class="MATCH_SCORE">
                <div class="SCORE_CONTAINER">
                  <input type="number" class="SCORE_INPUT" min="0" max="99" placeholder="0" />
                  <span class="SCORE_SEPARATOR">:</span>
                  <input type="number" class="SCORE_INPUT" min="0" max="99" placeholder="0" />
                </div>
                <button class="PREDICT_BUTTON">{{ CURRENT_LANGUAGE.PREDICT }}</button>
              </div>
              <div class="TEAM">
                <img src="https://via.placeholder.com/40" alt="Team 2" class="TEAM_LOGO" />
                <span class="TEAM_NAME">Argentina</span>
              </div>
            </div>
          </div>
          
          <!-- Match Card 2 -->
          <div class="MATCH_CARD">
            <div class="MATCH_HEADER">
              <span class="MATCH_TIME">{{ CURRENT_LANGUAGE.TOMORROW }} • 16:30</span>
              <span class="MATCH_STATUS">{{ CURRENT_LANGUAGE.TIME_LEFT }}: 22h 15min</span>
            </div>
            <div class="MATCH_TEAMS">
              <div class="TEAM">
                <img src="https://via.placeholder.com/40" alt="Team 1" class="TEAM_LOGO" />
                <span class="TEAM_NAME">France</span>
              </div>
              <div class="MATCH_SCORE">
                <div class="SCORE_CONTAINER">
                  <input type="number" class="SCORE_INPUT" min="0" max="99" placeholder="0" />
                  <span class="SCORE_SEPARATOR">:</span>
                  <input type="number" class="SCORE_INPUT" min="0" max="99" placeholder="0" />
                </div>
                <button class="PREDICT_BUTTON">{{ CURRENT_LANGUAGE.PREDICT }}</button>
              </div>
              <div class="TEAM">
                <img src="https://via.placeholder.com/40" alt="Team 2" class="TEAM_LOGO" />
                <span class="TEAM_NAME">Germany</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="DASHBOARD_ACTIONS">
        <button class="ACTION_BUTTON CREATE_GROUP" @click="showCreateGroupModal">
          <span class="BUTTON_ICON">+</span>
          {{ CURRENT_LANGUAGE.CREATE_GROUP }}
        </button>
        <button class="ACTION_BUTTON JOIN_GROUP" @click="showJoinGroupModal">
          <span class="BUTTON_ICON">🔗</span>
          {{ CURRENT_LANGUAGE.JOIN_GROUP }}
        </button>
      </div>
      
      <div class="GROUPS_SECTION" v-if="USER_GROUPS.length > 0">
        <h3>{{ CURRENT_LANGUAGE.YOUR_GROUPS }}</h3>
        <div class="GROUPS_GRID">
          <div 
            v-for="group in USER_GROUPS" 
            :key="group.ID" 
            class="GROUP_CARD"
            @click="navigateToGroup(group.ID)"
          >
            <div class="GROUP_CARD_HEADER">
              <h4>{{ group.NAME }}</h4>
              <span class="GROUP_MEMBERS">{{ group.MEMBER_COUNT }} {{ CURRENT_LANGUAGE.MEMBERS }}</span>
            </div>
            <p class="GROUP_DESCRIPTION">{{ group.DESCRIPTION }}</p>
          </div>
        </div>
      </div>
      
      <!-- Create Group Modal -->
      <div class="MODAL_OVERLAY" v-if="SHOW_CREATE_MODAL" @click="closeModals">
        <div class="MODAL_CONTENT" @click.stop>
          <div class="MODAL_HEADER">
            <h3>{{ CURRENT_LANGUAGE.CREATE_NEW_GROUP }}</h3>
            <button class="CLOSE_BUTTON" @click="closeModals">×</button>
          </div>
          <div class="MODAL_BODY">
            <div class="FORM_GROUP">
              <label for="group-name">{{ CURRENT_LANGUAGE.GROUP_NAME }}</label>
              <input 
                type="text" 
                id="group-name" 
                v-model="NEW_GROUP.NAME" 
                class="FORM_INPUT"
                :placeholder="CURRENT_LANGUAGE.GROUP_NAME_PLACEHOLDER"
              />
            </div>
            <div class="FORM_GROUP">
              <label for="group-description">{{ CURRENT_LANGUAGE.GROUP_DESCRIPTION }}</label>
              <textarea 
                id="group-description" 
                v-model="NEW_GROUP.DESCRIPTION" 
                class="FORM_INPUT TEXTAREA"
                :placeholder="CURRENT_LANGUAGE.GROUP_DESCRIPTION_PLACEHOLDER"
              ></textarea>
            </div>
          </div>
          <div class="MODAL_FOOTER">
            <button 
              class="PRIMARY_BUTTON" 
              @click="createGroup"
              :disabled="IS_CREATING_GROUP"
            >
              {{ IS_CREATING_GROUP ? CURRENT_LANGUAGE.CREATING : CURRENT_LANGUAGE.CREATE }}
            </button>
          </div>
          <div v-if="GROUP_ERROR" class="ERROR_MESSAGE">
            {{ GROUP_ERROR }}
          </div>
        </div>
      </div>
      
      <!-- Join Group Modal -->
      <div class="MODAL_OVERLAY" v-if="SHOW_JOIN_MODAL" @click="closeModals">
        <div class="MODAL_CONTENT" @click.stop>
          <div class="MODAL_HEADER">
            <h3>{{ CURRENT_LANGUAGE.JOIN_EXISTING_GROUP }}</h3>
            <button class="CLOSE_BUTTON" @click="closeModals">×</button>
          </div>
          <div class="MODAL_BODY">
            <div class="FORM_GROUP">
              <label for="group-code">{{ CURRENT_LANGUAGE.GROUP_CODE }}</label>
              <input 
                type="text" 
                id="group-code" 
                v-model="JOIN_GROUP_CODE" 
                class="FORM_INPUT"
                :placeholder="CURRENT_LANGUAGE.GROUP_CODE_PLACEHOLDER"
              />
            </div>
          </div>
          <div class="MODAL_FOOTER">
            <button 
              class="PRIMARY_BUTTON" 
              @click="joinGroup"
              :disabled="IS_JOINING_GROUP"
            >
              {{ IS_JOINING_GROUP ? CURRENT_LANGUAGE.JOINING : CURRENT_LANGUAGE.JOIN }}
            </button>
          </div>
          <div v-if="GROUP_ERROR" class="ERROR_MESSAGE">
            {{ GROUP_ERROR }}
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { testSupabaseConnection } from '../services/supabase'

export default {
  name: 'DashboardPage',
  data() {
    return {
      USER_GROUPS: [],
      IS_LOADING: false,
      SHOW_CREATE_MODAL: false,
      SHOW_JOIN_MODAL: false,
      IS_CREATING_GROUP: false,
      IS_JOINING_GROUP: false,
      GROUP_ERROR: '',
      JOIN_GROUP_CODE: '',
      NEW_GROUP: {
        NAME: '',
        DESCRIPTION: ''
      },
      CURRENT_LANGUAGE: {
        WELCOME: 'Welcome to Bimba Bolao',
        DASHBOARD_MESSAGE: 'Create or join a prediction group to start playing!',
        SETTINGS: 'Settings',
        CREATE_GROUP: 'Create Group',
        JOIN_GROUP: 'Join Group',
        YOUR_GROUPS: 'Your Groups',
        MEMBERS: 'members',
        CREATE_NEW_GROUP: 'Create New Group',
        JOIN_EXISTING_GROUP: 'Join Existing Group',
        GROUP_NAME: 'Group Name',
        GROUP_NAME_PLACEHOLDER: 'Enter a name for your group',
        GROUP_DESCRIPTION: 'Description',
        GROUP_DESCRIPTION_PLACEHOLDER: 'Describe your group (optional)',
        GROUP_CODE: 'Invitation Code',
        GROUP_CODE_PLACEHOLDER: 'Enter the group invitation code',
        CREATE: 'Create Group',
        CREATING: 'Creating...',
        JOIN: 'Join Group',
        JOINING: 'Joining...',
        GROUP_CREATED: 'Group created successfully!',
        GROUP_JOINED: 'You have joined the group!',
        ERROR_CREATE_GROUP: 'Failed to create group. Please try again.',
        ERROR_JOIN_GROUP: 'Failed to join group. Invalid code or you are already a member.',
        ERROR_LOAD_GROUPS: 'Failed to load your groups. Please refresh the page.',
        UPCOMING_MATCHES: 'Upcoming Matches',
        TODAY: 'Today',
        TOMORROW: 'Tomorrow',
        TIME_LEFT: 'Time left',
        PREDICT: 'Predict'
      }
    }
  },
  mounted() {
    this.applyTheme()
    this.loadUserGroups()
    this.testConnection()
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
    navigateToProfile() {
      this.$router.push('/profile')
    },
    navigateToGroup(groupId) {
      this.$router.push(`/group/${groupId}`)
    },
    showCreateGroupModal() {
      this.SHOW_CREATE_MODAL = true
      this.SHOW_JOIN_MODAL = false
      this.GROUP_ERROR = ''
    },
    showJoinGroupModal() {
      this.SHOW_JOIN_MODAL = true
      this.SHOW_CREATE_MODAL = false
      this.GROUP_ERROR = ''
    },
    closeModals() {
      this.SHOW_CREATE_MODAL = false
      this.SHOW_JOIN_MODAL = false
      this.GROUP_ERROR = ''
      this.NEW_GROUP = {
        NAME: '',
        DESCRIPTION: ''
      }
      this.JOIN_GROUP_CODE = ''
    },
    async loadUserGroups() {
      this.IS_LOADING = true
      
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        // Get user's groups
        const { data, error } = await this.$supabase
          .from('GROUP_MEMBERS')
          .select(`
            GROUP_ID,
            GROUPS:GROUP_ID (
              ID,
              NAME,
              DESCRIPTION,
              CREATED_AT
            )
          `)
          .eq('USER_ID', user.id)
        
        if (error) throw error
        
        // Format the groups data
        if (data) {
          // Get member counts for each group
          const groupIds = data.map(item => item.GROUP_ID)
          
          const { data: memberCounts, error: countError } = await this.$supabase
            .from('GROUP_MEMBERS')
            .select('GROUP_ID, count')
            .in('GROUP_ID', groupIds)
            .group('GROUP_ID')
          
          if (countError) throw countError
          
          // Map the data to the format we need
          this.USER_GROUPS = data.map(item => {
            const group = item.GROUPS
            const memberCount = memberCounts.find(m => m.GROUP_ID === group.ID)
            
            return {
              ID: group.ID,
              NAME: group.NAME,
              DESCRIPTION: group.DESCRIPTION,
              CREATED_AT: group.CREATED_AT,
              MEMBER_COUNT: memberCount ? memberCount.count : 1
            }
          })
        }
      } catch (error) {
        console.error('Error loading groups:', error)
      } finally {
        this.IS_LOADING = false
      }
    },
    async testConnection() {
      const result = await testSupabaseConnection()
      console.log('Supabase connection test result:', result)
      if (!result.success) {
        console.error('Connection test failed:', result.message)
      }
    },
    async createGroup() {
      if (!this.NEW_GROUP.NAME.trim()) {
        this.GROUP_ERROR = 'Group name is required'
        return
      }
      
      this.IS_CREATING_GROUP = true
      this.GROUP_ERROR = ''
      
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        console.log('Creating group with user ID:', user.id)
        
        // Try a direct approach with a single RPC call
        try {
          const { data: directResult, error: directError } = await this.$supabase.rpc(
            'create_group_with_member',
            {
              group_name: this.NEW_GROUP.NAME,
              group_description: this.NEW_GROUP.DESCRIPTION,
              user_id: user.id
            }
          )
          
          if (directError) {
            console.error('Direct group creation failed:', directError)
          } else if (directResult) {
            console.log('Group created successfully via RPC:', directResult)
            this.closeModals()
            this.loadUserGroups()
            return
          }
        } catch (rpcError) {
          console.error('RPC error:', rpcError)
          // Continue with the standard approach if RPC fails
        }
        
        // Standard approach - Create a new group
        const { data: groupData, error: groupError } = await this.$supabase
          .from('GROUPS')
          .insert({
            NAME: this.NEW_GROUP.NAME,
            DESCRIPTION: this.NEW_GROUP.DESCRIPTION,
            CREATED_BY: user.id
          })
          .select()
        
        if (groupError) {
          console.error('Error creating group:', groupError)
          this.GROUP_ERROR = `Failed to create group: ${JSON.stringify(groupError)}`
          this.IS_CREATING_GROUP = false
          return
        }
        
        if (!groupData || groupData.length === 0) {
          // Try an alternative approach - maybe the insert worked but select failed
          const { data: checkGroups, error: checkError } = await this.$supabase
            .from('GROUPS')
            .select('ID')
            .eq('NAME', this.NEW_GROUP.NAME)
            .eq('CREATED_BY', user.id)
            .order('CREATED_AT', { ascending: false })
            .limit(1)
          
          if (checkError || !checkGroups || checkGroups.length === 0) {
            console.error('No group data returned after insert and check failed:', checkError)
            this.GROUP_ERROR = 'Failed to create group: No data returned'
            this.IS_CREATING_GROUP = false
            return
          }
          
          console.log('Found group via check query:', checkGroups[0])
          const newGroupId = checkGroups[0].ID
          
          // Add the creator as a member
          // eslint-disable-next-line no-unused-vars
          const { data: memberData, error: memberError } = await this.$supabase
            .from('GROUP_MEMBERS')
            .insert({
              GROUP_ID: newGroupId,
              USER_ID: user.id,
              ROLE: 'ADMIN'
            })
            .select()
          
          if (memberError) {
            console.error('Error adding member:', memberError)
            this.GROUP_ERROR = `Failed to add member: ${JSON.stringify(memberError)}`
            this.IS_CREATING_GROUP = false
            return
          }
          
          // Close modal and reload groups
          this.closeModals()
          this.loadUserGroups()
          return
        }
        
        const newGroupId = groupData[0].ID
        console.log('Group created with ID:', newGroupId)
        
        // Add the creator as a member
        // eslint-disable-next-line no-unused-vars
        const { data: memberData, error: memberError } = await this.$supabase
          .from('GROUP_MEMBERS')
          .insert({
            GROUP_ID: newGroupId,
            USER_ID: user.id,
            ROLE: 'ADMIN'
          })
          .select()
        
        if (memberError) {
          console.error('Error adding member:', memberError)
          this.GROUP_ERROR = `Failed to add member: ${JSON.stringify(memberError)}`
          this.IS_CREATING_GROUP = false
          return
        }
        
        console.log('Added user as admin member')
        
        // Generate an invitation code
        const inviteCode = this.generateInviteCode()
        console.log('Generated invite code:', inviteCode)
        
        // eslint-disable-next-line no-unused-vars
        const { data: inviteData, error: inviteError } = await this.$supabase
          .from('GROUP_INVITES')
          .insert({
            GROUP_ID: newGroupId,
            CODE: inviteCode,
            CREATED_BY: user.id,
            EXPIRES_AT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
          })
          .select()
        
        if (inviteError) {
          console.error('Error creating invite:', inviteError)
          this.GROUP_ERROR = `Failed to create invite: ${JSON.stringify(inviteError)}`
          // Don't return here, we can still proceed without an invite code
        } else {
          console.log('Created invite code successfully')
        }
        
        // Close modal and reload groups
        this.closeModals()
        this.loadUserGroups()
        
      } catch (error) {
        console.error('Error creating group:', error)
        this.GROUP_ERROR = `Error: ${error ? JSON.stringify(error) : this.CURRENT_LANGUAGE.ERROR_CREATE_GROUP}`
      } finally {
        this.IS_CREATING_GROUP = false
      }
    },
    async joinGroup() {
      if (!this.JOIN_GROUP_CODE.trim()) {
        this.GROUP_ERROR = 'Invitation code is required'
        return
      }
      
      this.IS_JOINING_GROUP = true
      this.GROUP_ERROR = ''
      
      try {
        const { data: { user } } = await this.$supabase.auth.getUser()
        
        if (!user) {
          this.$router.push('/login')
          return
        }
        
        // Find the group by invitation code
        const { data: inviteData, error: inviteError } = await this.$supabase
          .from('GROUP_INVITES')
          .select('GROUP_ID, EXPIRES_AT')
          .eq('CODE', this.JOIN_GROUP_CODE)
          .single()
        
        if (inviteError || !inviteData) {
          this.GROUP_ERROR = this.CURRENT_LANGUAGE.ERROR_JOIN_GROUP
          return
        }
        
        // Check if invitation is expired
        if (new Date(inviteData.EXPIRES_AT) < new Date()) {
          this.GROUP_ERROR = 'This invitation code has expired'
          return
        }
        
        // Check if user is already a member
        const { data: existingMember } = await this.$supabase
          .from('GROUP_MEMBERS')
          .select('ID')
          .eq('GROUP_ID', inviteData.GROUP_ID)
          .eq('USER_ID', user.id)
          .single()
        
        if (existingMember) {
          this.GROUP_ERROR = 'You are already a member of this group'
          return
        }
        
        // Add user as a member
        const { error: joinError } = await this.$supabase
          .from('GROUP_MEMBERS')
          .insert({
            GROUP_ID: inviteData.GROUP_ID,
            USER_ID: user.id,
            ROLE: 'MEMBER'
          })
        
        if (joinError) throw joinError
        
        // Close modal and reload groups
        this.closeModals()
        this.loadUserGroups()
        
      } catch (error) {
        console.error('Error joining group:', error)
        this.GROUP_ERROR = this.CURRENT_LANGUAGE.ERROR_JOIN_GROUP
      } finally {
        this.IS_JOINING_GROUP = false
      }
    },
    generateInviteCode() {
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      let code = ''
      // Generate a longer code (10 characters) for better uniqueness
      for (let i = 0; i < 10; i++) {
        code += characters.charAt(Math.floor(Math.random() * characters.length))
      }
      // Add timestamp to ensure uniqueness
      return code + '-' + Date.now().toString().substring(7)
    }
  }
}
</script>

<style scoped>
.DASHBOARD_CONTAINER {
  min-height: 100vh;
  background-color: var(--bg-primary);
  background-image: var(--pattern-overlay);
}

.DASHBOARD_HEADER {
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

.HEADER_LOGO {
  display: flex;
  align-items: center;
  gap: 12px;
}

.LOGO_IMAGE {
  width: 40px;
  height: 40px;
  object-fit: contain;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.DASHBOARD_HEADER h1 {
  font-size: 24px;
  font-weight: 700;
  margin: 0;
  letter-spacing: 0.5px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.HEADER_ACTIONS {
  display: flex;
  align-items: center;
  gap: 12px;
}

.PROFILE_BUTTON {
  background-color: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 18px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 6px rgba(59, 130, 246, 0.3);
}

.PROFILE_BUTTON:hover {
  background-color: #2563eb;
  transform: translateY(-2px);
  box-shadow: 0 6px 10px rgba(59, 130, 246, 0.4);
}

.DASHBOARD_CONTENT {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px;
}

.DASHBOARD_WELCOME {
  background-color: var(--card-bg);
  border-radius: 16px;
  box-shadow: var(--card-shadow);
  padding: 30px;
  margin-bottom: 32px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: card-appear 0.5s ease-out forwards;
}

.DASHBOARD_WELCOME h2 {
  font-size: 24px;
  margin-bottom: 16px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  display: inline-block;
  font-weight: 700;
}

.DASHBOARD_WELCOME p {
  font-size: 16px;
  color: var(--text-secondary);
  line-height: 1.6;
}

.DASHBOARD_ACTIONS {
  display: flex;
  gap: 16px;
  margin-bottom: 40px;
}

.ACTION_BUTTON {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: white;
  border: none;
  border-radius: 12px;
  padding: 20px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
}

.ACTION_BUTTON:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
}

.CREATE_GROUP {
  background: linear-gradient(135deg, #3b82f6 0%, #1e40af 100%);
}

.JOIN_GROUP {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.BUTTON_ICON {
  font-size: 20px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
}

.GROUPS_SECTION {
  margin-top: 40px;
}

.GROUPS_SECTION h3 {
  font-size: 20px;
  margin-bottom: 24px;
  color: var(--text-primary);
  font-weight: 600;
}

.GROUPS_GRID {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

.GROUP_CARD {
  background-color: var(--card-bg);
  border-radius: 12px;
  box-shadow: var(--card-shadow);
  padding: 24px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s;
  cursor: pointer;
}

.GROUP_CARD:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
  border-color: var(--accent-primary);
}

.GROUP_CARD_HEADER {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.GROUP_CARD h4 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  color: var(--text-primary);
}

.GROUP_MEMBERS {
  font-size: 12px;
  color: var(--text-secondary);
  background-color: rgba(255, 255, 255, 0.1);
  padding: 4px 8px;
  border-radius: 12px;
}

.GROUP_DESCRIPTION {
  font-size: 14px;
  color: var(--text-secondary);
  line-height: 1.5;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
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
  margin: 0;
  color: var(--text-primary);
  font-weight: 600;
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

.MODAL_FOOTER {
  padding: 16px 24px 24px;
  display: flex;
  justify-content: flex-end;
}

.FORM_GROUP {
  margin-bottom: 20px;
}

.FORM_GROUP label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 8px;
  color: var(--text-secondary);
}

.FORM_INPUT {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
  border: 1px solid var(--input-border);
  border-radius: 8px;
  background-color: var(--input-bg);
  color: var(--text-primary);
  transition: all 0.3s;
}

.FORM_INPUT:focus {
  outline: none;
  border-color: var(--accent-primary);
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.3);
}

.TEXTAREA {
  min-height: 100px;
  resize: vertical;
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
}

.PRIMARY_BUTTON:hover:not(:disabled) {
  background-color: var(--button-hover-bg);
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(59, 130, 246, 0.3);
}

.PRIMARY_BUTTON:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.ERROR_MESSAGE {
  margin: 0 24px 24px;
  padding: 12px 16px;
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--error-color);
  border-radius: 8px;
  font-size: 14px;
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

/* Match Templates Styles */
.MATCHES_SECTION {
  margin-bottom: 40px;
}

.MATCHES_SECTION h3 {
  font-size: 20px;
  margin-bottom: 24px;
  color: var(--text-primary);
  font-weight: 600;
}

.MATCHES_GRID {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 24px;
}

.MATCH_CARD {
  background-color: var(--card-bg);
  border-radius: 12px;
  box-shadow: var(--card-shadow);
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s;
}

.MATCH_CARD:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
  border-color: var(--accent-primary);
}

.MATCH_HEADER {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.MATCH_TIME {
  font-size: 14px;
  font-weight: 600;
  color: var(--accent-primary);
}

.MATCH_STATUS {
  font-size: 14px;
  color: var(--text-secondary);
  background-color: rgba(255, 255, 255, 0.1);
  padding: 4px 10px;
  border-radius: 12px;
}

.MATCH_TEAMS {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.TEAM {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  width: 30%;
}

.TEAM_LOGO {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid rgba(255, 255, 255, 0.1);
}

.TEAM_NAME {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  text-align: center;
}

.MATCH_SCORE {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  width: 40%;
}

.SCORE_CONTAINER {
  display: flex;
  align-items: center;
  gap: 8px;
}

.SCORE_INPUT {
  width: 50px;
  height: 50px;
  text-align: center;
  font-size: 20px;
  font-weight: 700;
  border: 2px solid var(--input-border);
  border-radius: 8px;
  background-color: var(--input-bg);
  color: var(--text-primary);
}

.SCORE_INPUT:focus {
  outline: none;
  border-color: var(--accent-primary);
}

.SCORE_SEPARATOR {
  font-size: 24px;
  font-weight: 700;
  color: var(--text-secondary);
}

.PREDICT_BUTTON {
  background-color: var(--accent-primary);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  width: 100%;
  max-width: 120px;
}

.PREDICT_BUTTON:hover {
  background-color: var(--button-hover-bg);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3);
}

@media (max-width: 768px) {
  .MATCHES_GRID {
    grid-template-columns: 1fr;
  }
  
  .DASHBOARD_ACTIONS {
    flex-direction: column;
  }
  
  .GROUPS_GRID {
    grid-template-columns: 1fr;
  }
}
</style>
