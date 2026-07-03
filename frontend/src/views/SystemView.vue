<template>
  <div class="system-view">
    <el-tabs v-model="activeTab" type="border-card" class="system-tabs">
      <!-- ════════════ Tab 1: Binlog Management ════════════ -->
      <el-tab-pane label="Binlog 管理" name="binlog">
        <el-card shadow="never" :body-style="{ padding: '20px' }">
          <el-space>
            <el-button type="primary" :loading="loading" @click="loadBinlog">刷新</el-button>
            <el-button type="danger" @click="purgeConfirm">清除 Binlog</el-button>
          </el-space>

          <el-table :data="binlogs" border stripe style="margin-top: 16px; width: 100%">
            <el-table-column prop="Log_name" label="日志文件" />
            <el-table-column prop="File_size" label="大小(bytes)" :formatter="formatSize" />
            <el-table-column prop="Encrypted" label="加密" width="80" />
          </el-table>

          <el-descriptions v-if="totalSize" :column="1" border style="margin-top: 16px; max-width: 400px">
            <el-descriptions-item label="总文件数">{{ binlogs.length }}</el-descriptions-item>
            <el-descriptions-item label="总大小">{{ formatSize(null, null, totalSize) }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-tab-pane>

      <!-- ════════════ Tab 2: Admin Management ════════════ -->
      <el-tab-pane label="管理员管理" name="users">
        <el-card shadow="never" :body-style="{ padding: '20px' }">
          <el-table :data="users" border stripe style="width: 100%">
            <el-table-column label="用户名" prop="username" width="100" />
            <el-table-column label="密码" width="160">
              <template #default="{ row }">
                <span v-if="editingPwd !== row.username">{{ '••••••••' }}</span>
                <el-input
                  v-else
                  v-model="pwdForm.password"
                  type="password" show-password size="small"
                  placeholder="新密码" style="width: 100px"
                />
                <template v-if="editingPwd === row.username">
                  <el-button type="primary" link size="small" @click="savePassword(row)">保存</el-button>
                  <el-button link size="small" @click="editingPwd = ''">取消</el-button>
                </template>
                <el-button v-else type="primary" link size="small" @click="editPassword(row)">修改</el-button>
              </template>
            </el-table-column>
            <el-table-column label="权限" prop="role" width="110">
              <template #default="{ row }">
                <el-tag :type="row.role === 'super' ? 'danger' : 'info'">
                  {{ row.role === 'super' ? '超级管理员' : '普通用户' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="80">
              <template #default="{ row }">
                <el-switch
                  :model-value="row.status === 'enabled'"
                  :disabled="row.username === 'admin' || row.username === 'query'"
                  @change="(val) => toggleStatus(row, val)"
                />
              </template>
            </el-table-column>
            <el-table-column label="姓名" width="120">
              <template #default="{ row }">
                <el-input v-model="row._name" size="small" @blur="saveProfile(row)" />
              </template>
            </el-table-column>
            <el-table-column label="联系方式" width="180">
              <template #default="{ row }">
                <el-input v-model="row._contact" size="small" @blur="saveProfile(row)" />
              </template>
            </el-table-column>
            <el-table-column label="备注" min-width="200">
              <template #default="{ row }">
                <el-input v-model="row._notes" size="small" @blur="saveProfile(row)" />
              </template>
            </el-table-column>
          </el-table>

          <el-alert
            type="info" show-icon :closable="false"
            style="margin-top: 16px"
          >
            <template #title>
              说明：admin 和 query 为系统默认用户，不可删除、不可更改权限。
              admin 拥有所有操作权限，query 仅可操作日志查询、数据统计、财务报表。
            </template>
          </el-alert>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <!-- ════════════ Login Dialog ════════════ -->
    <el-dialog v-model="loginVisible" title="用户登录" width="400px" :close-on-click-modal="false" :close-on-press-escape="false" :show-close="false">
      <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="loginForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="loginForm.password" type="password" show-password placeholder="请输入密码" @keyup.enter="doLogin" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" :loading="loginLoading" @click="doLogin">登录</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../api'

// ── Tab ──
const activeTab = ref('binlog')

// ── Binlog ──
const binlogs = ref([])
const loading = ref(false)
const totalSize = computed(() => binlogs.value.reduce((sum, b) => sum + (b.File_size || 0), 0))

async function loadBinlog() {
  loading.value = true
  try {
    const { data } = await api.system.binlog()
    binlogs.value = data.binlogs || []
  } finally {
    loading.value = false
  }
}

function formatSize(row, col, val) {
  if (!val) return '0'
  if (val > 1073741824) return (val / 1073741824).toFixed(2) + ' GB'
  if (val > 1048576) return (val / 1048576).toFixed(2) + ' MB'
  if (val > 1024) return (val / 1024).toFixed(2) + ' KB'
  return val + ' B'
}

async function purgeConfirm() {
  await ElMessageBox.confirm(
    '确认清除所有 binlog？此操作不可恢复。',
    '警告',
    { confirmButtonText: '确认清除', cancelButtonText: '取消', type: 'warning' }
  )
  await api.system.purge({})
  ElMessage.success('Binlog 已清除')
  await loadBinlog()
}

// ── User Management ──
const users = ref([])
const editingPwd = ref('')
const pwdForm = reactive({ password: '' })

async function loadUsers() {
  const { data } = await api.system.users()
  users.value = (data.users || []).map(u => ({
    ...u,
    _name: u.name || '',
    _contact: u.contact || '',
    _notes: u.notes || '',
  }))
}

function editPassword(row) {
  editingPwd.value = row.username
  pwdForm.password = ''
  nextTick(() => {
    const inp = document.querySelector('.system-view input[type="password"]')
    if (inp) inp.focus()
  })
}

async function savePassword(row) {
  if (!pwdForm.password || pwdForm.password.length < 4) {
    ElMessage.warning('密码至少4位')
    return
  }
  await api.system.updatePassword(row.username, { password: pwdForm.password })
  ElMessage.success('密码已修改')
  editingPwd.value = ''
}

async function toggleStatus(row, enabled) {
  const status = enabled ? 'enabled' : 'disabled'
  await api.system.updateStatus(row.username, { status })
  row.status = status
  ElMessage.success(enabled ? '已启用' : '已禁用')
}

let _profileTimer = null
async function saveProfile(row) {
  if (_profileTimer) clearTimeout(_profileTimer)
  _profileTimer = setTimeout(async () => {
    try {
      await api.system.updateProfile(row.username, {
        name: row._name,
        contact: row._contact,
        notes: row._notes,
      })
    } catch { /* ignore */ }
  }, 800)
}

onMounted(() => {
  loadBinlog()
  loadUsers()
})
</script>

<style scoped>
.system-view { width: 100%; }
.system-tabs { height: 100%; display: flex; flex-direction: column; }
.system-tabs :deep(.el-tabs__content) { flex: 1; overflow-y: auto; }
.system-tabs :deep(.el-tab-pane) { height: 100%; }
</style>
