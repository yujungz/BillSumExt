<template>
  <div class="config-view">
    <el-card>
      <template #header><span class="card-title">参数配置</span></template>

      <el-tabs v-model="activeTab" type="border-card">
        <!-- Tab 1: 本地数据库 -->
        <el-tab-pane label="本地数据库" name="mysql">
          <el-form :model="config.mysql" label-width="120px" style="max-width: 600px">
            <el-form-item label="容器名称">
              <el-input v-model="config.mysql.container_name" />
            </el-form-item>
            <el-form-item label="主机">
              <el-input v-model="config.mysql.host" />
            </el-form-item>
            <el-form-item label="端口">
              <el-input-number v-model="config.mysql.port" :min="1" :max="65535" />
            </el-form-item>
            <el-form-item label="用户名">
              <el-input v-model="config.mysql.user" />
            </el-form-item>
            <el-form-item label="密码">
              <el-input v-model="config.mysql.password" type="password" show-password />
            </el-form-item>
            <el-form-item>
              <el-button type="success" @click="testMysql">测试连接</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- Tab 2: 站点SSH配置 -->
        <el-tab-pane label="站点SSH配置" name="ssh">
          <div class="site-tabs-wrap">
          <el-tabs v-model="activeSite" type="card">
            <el-tab-pane v-for="site in sites" :key="site" :label="site" :name="site">
              <div v-if="config.sites[site]">
                <el-form :model="config.sites[site]" label-width="120px" style="max-width: 900px">
                  <el-form-item label="填充模式">
                    <el-select v-model="config.sites[site].uptnew_mode">
                      <el-option label="完整 (ex_users+ex_tokens+ex_channels)" value="full" />
                      <el-option label="简单 (ex_users+ex_channels)" value="simple" />
                      <el-option label="最小 (仅注册)" value="minimal" />
                    </el-select>
                  </el-form-item>

                  <h5>SSH 连接</h5>
                  <el-form-item label="主机">
                    <el-input v-model="config.sites[site].ssh.host" />
                  </el-form-item>
                  <el-form-item label="端口">
                    <el-input-number v-model="config.sites[site].ssh.port" :min="1" :max="65535" />
                  </el-form-item>
                  <el-form-item label="用户名">
                    <el-input v-model="config.sites[site].ssh.user" />
                  </el-form-item>
                  <el-form-item label="密钥路径">
                    <div style="display: flex; gap: 8px; align-items: center">
                      <el-input v-model="config.sites[site].ssh.key_path" placeholder="容器内密钥路径" style="flex: 1" />
                      <el-button type="primary" :loading="mountLoading[site]" @click="triggerMount(site)">挂载</el-button>
                      <input ref="fileInputs" type="file" style="display: none" @change="onFileSelected($event, site)" />
                    </div>
                  </el-form-item>
                  <el-form-item label="远程路径">
                    <el-input v-model="config.sites[site].ssh.remote_path" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="success" @click="testSsh(site)">测试 SSH</el-button>
                  </el-form-item>

                  <h5>远程数据库</h5>
                  <el-form-item label="容器名">
                    <el-input v-model="config.sites[site].remote_db.container_name" />
                  </el-form-item>
                  <el-form-item label="数据库名">
                    <el-input v-model="config.sites[site].remote_db.db_name" />
                  </el-form-item>
                  <el-form-item label="密码">
                    <el-input v-model="config.sites[site].remote_db.password" type="password" show-password />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="success" @click="testRemoteDb(site)">测试连接</el-button>
                  </el-form-item>
                </el-form>
              </div>
            </el-tab-pane>
          </el-tabs>
          <div class="site-tab-actions">
            <el-button size="small" :icon="Plus" circle title="新增站点" @click="addSite" />
            <el-button size="small" :icon="Minus" circle title="删除当前站点" @click="deleteSite" />
          </div>
          </div>
        </el-tab-pane>

        <!-- Tab 3: 业务参数 -->
        <el-tab-pane label="业务参数" name="business">
          <el-form :model="config.business" label-width="140px" style="max-width: 500px">
            <el-form-item label="采购提成比例">
              <el-input-number v-model="config.business.purchase_commission_rate" :min="0" :max="1" :step="0.01" :precision="2" />
            </el-form-item>
            <el-form-item label="销售提成比例">
              <el-input-number v-model="config.business.sales_commission_rate" :min="0" :max="1" :step="0.01" :precision="2" />
            </el-form-item>
            <el-form-item label="美中汇率">
              <el-input-number v-model="config.business.us_cny_rate" :min="0" :step="0.01" :precision="2" />
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>

      <el-divider />
      <el-button type="primary" @click="saveConfig">保存配置</el-button>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Minus } from '@element-plus/icons-vue'
import api from '../api'
import { refreshSites } from '../composables/useSites'

const DEFAULT_SITE_NAMES = ['ai', 'csp', 'pinova', 'wzg', 'qn', 'digitalcloud', 'wshk']
const sites = ref([...DEFAULT_SITE_NAMES])
const activeTab = ref('mysql')
const activeSite = ref('wzg')
const fileInputs = ref([])
const mountLoading = reactive({})
const pendingMountSite = ref('')

const SSH_DEFAULT = 'burncloud123456!qwf'
const KEY_PATH_DEFAULT = '/ssh_keys/host20260311'

const SITE_DEFAULTS = {
  ai: { ssh: { host: 'shadow.burncloud.com', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'backup_198.11.179.205-ai', db_name: 'new-api', password: SSH_DEFAULT }, uptnew_mode: 'full' },
  csp: { ssh: { host: 'shadow.burncloud.com', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'backup_198.11.179.205-csp', db_name: 'new-api', password: SSH_DEFAULT }, uptnew_mode: 'simple' },
  pinova: { ssh: { host: 'shadow.burncloud.com', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'backup_198.11.179.205-pinova', db_name: 'new-api', password: SSH_DEFAULT }, uptnew_mode: 'full' },
  wzg: { ssh: { host: 'shadow.burncloud.com', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'backup_48.211.172.173-wzg', db_name: 'new-api', password: SSH_DEFAULT }, uptnew_mode: 'full' },
  qn: { ssh: { host: '120.26.136.61', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'burncloud-mysql', db_name: 'new-api', password: 'abc123' }, uptnew_mode: 'minimal' },
  digitalcloud: { ssh: { host: 'shadow.burncloud.com', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'backup_198.11.182.119-digitalcloud', db_name: 'new-api', password: 'abc123' }, uptnew_mode: 'minimal' },
  wshk: { ssh: { host: 'wshk.burncloud.com', user: 'root', key_path: KEY_PATH_DEFAULT }, remote_db: { container_name: 'main01-mysql', db_name: 'new-api', password: 'burncloud123456qwe' }, uptnew_mode: 'full' },
}

const config = reactive({
  mysql: { host: 'localhost', port: 3306, user: 'root', password: '123456', container_name: 'test-mysql8' },
  sites: {},
  business: {
    purchase_commission_rate: 0.3,
    sales_commission_rate: 0.3,
    us_cny_rate: 6.91,
  },
})

function buildSiteConfig(name, d) {
  const src = d || {}
  return {
    name,
    ssh: { host: '', port: 22, user: 'root', key_path: '', remote_path: '~/data/', backup: 1, ...(src.ssh || {}) },
    remote_db: { container_name: '', db_name: 'new-api', password: '', ...(src.remote_db || {}) },
    uptnew_mode: src.uptnew_mode,
  }
}

onMounted(async () => {
  try {
    const { data } = await api.settings.get()
    Object.assign(config.mysql, data.mysql)
    if (data.business) Object.assign(config.business, data.business)
    // 站点列表来自已存配置(支持界面增删后持久化); 空则回退默认
    const names = data.sites && Object.keys(data.sites).length ? Object.keys(data.sites) : [...DEFAULT_SITE_NAMES]
    sites.value = names
    for (const s of names) {
      config.sites[s] = buildSiteConfig(s, data.sites?.[s] || SITE_DEFAULTS[s])
    }
  } catch {
    sites.value = [...DEFAULT_SITE_NAMES]
    for (const s of DEFAULT_SITE_NAMES) {
      config.sites[s] = buildSiteConfig(s, SITE_DEFAULTS[s])
    }
  }
  if (!sites.value.includes(activeSite.value)) activeSite.value = sites.value[0]
})

async function testMysql() {
  const { data } = await api.settings.testMysql(config.mysql)
  data.success ? ElMessage.success(data.message) : ElMessage.error(data.message)
}

async function testSsh(site) {
  const { data } = await api.settings.testSsh(config.sites[site].ssh)
  data.success ? ElMessage.success(data.message) : ElMessage.error(data.message)
}

async function testRemoteDb(site) {
  const { data } = await api.settings.testRemoteDb({ ssh: config.sites[site].ssh, remote_db: config.sites[site].remote_db })
  data.success ? ElMessage.success(data.message) : ElMessage.error(data.message)
}

async function persistConfig() {
  await api.settings.save({ mysql: config.mysql, sites: config.sites, business: config.business })
}

async function saveConfig() {
  await persistConfig()
  ElMessage.success('配置已保存')
}

async function addSite() {
  let name
  try {
    const { value } = await ElMessageBox.prompt(
      '请输入站点名（字母开头，仅含字母/数字/下划线）。对应本地库为 sum_<站点名>',
      '新增站点',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputValidator: (v) => {
          const s = (v || '').trim()
          if (!s) return '站点名不能为空'
          if (!/^[A-Za-z][A-Za-z0-9_]*$/.test(s)) return '只能字母开头，且仅含字母、数字、下划线'
          if (sites.value.includes(s)) return '站点名已存在'
          return true
        },
      },
    )
    name = value.trim()
  } catch { return }
  // 复制当前选中站点的参数到新站点
  const cur = config.sites[activeSite.value] || config.sites[sites.value[0]]
  config.sites[name] = {
    name,
    ssh: { ...cur.ssh },
    remote_db: { ...cur.remote_db },
    uptnew_mode: cur.uptnew_mode,
  }
  sites.value = [...sites.value, name]
  activeSite.value = name
  ElMessage.success(`已新增站点 ${name}（本地库 sum_${name}）`)
  await persistConfig()
  await refreshSites()
}

async function deleteSite() {
  if (sites.value.length <= 1) {
    ElMessage.warning('最后一个站点不能删除')
    return
  }
  const site = activeSite.value
  try {
    await ElMessageBox.confirm(
      `确定删除站点「${site}」？本地库 sum_${site} 的数据不会被删除。`,
      '删除站点',
      { confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning' },
    )
  } catch { return }
  // 删除后跳转：非首个→上一个；首个→下一个
  const idx = sites.value.indexOf(site)
  const next = idx > 0 ? sites.value[idx - 1] : sites.value[idx + 1]
  sites.value = sites.value.filter(s => s !== site)
  delete config.sites[site]
  activeSite.value = next
  ElMessage.success(`已删除站点 ${site}`)
  await persistConfig()
  await refreshSites()
}

function triggerMount(site) {
  pendingMountSite.value = site
  const input = document.createElement('input')
  input.type = 'file'
  input.onchange = (e) => onFileSelected(e, site)
  input.click()
}

async function onFileSelected(event, site) {
  const file = event.target.files?.[0]
  if (!file) return
  mountLoading[site] = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    const { data } = await api.settings.mountKey(formData)
    if (data.success) {
      config.sites[site].ssh.key_path = data.container_path
      ElMessage.success(`密钥已挂载: ${data.container_path}`)
    } else {
      ElMessage.error('挂载失败')
    }
  } catch (e) {
    ElMessage.error('挂载失败: ' + (e.response?.data?.detail || e.message))
  } finally {
    mountLoading[site] = false
  }
}
</script>

<style scoped>
.config-view { width: 100%; }
.card-title { font-size: 16px; font-weight: bold; }
h5 { margin: 12px 0 6px; color: #606266; }
.site-tabs-wrap { position: relative; }
.site-tab-actions { position: absolute; right: 10px; top: 6px; z-index: 2; display: flex; gap: 6px; }
.site-tabs-wrap :deep(.el-tabs__header) { padding-right: 86px; }
</style>
