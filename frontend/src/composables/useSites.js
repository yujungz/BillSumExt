import { ref } from 'vue'
import api from '../api'

// 全局共享站点列表(响应式): 配置页增删站点后调用 refreshSites() 刷新,
// 各视图(传输/查询/统计/财务)通过 useSites() 共用同一份, 自动响应变化。
const sites = ref([])
let _loaded = false

export async function refreshSites() {
  try {
    const { data } = await api.settings.sites()
    sites.value = data.sites || []
  } catch { /* 加载失败保持原值 */ }
  _loaded = true
  return sites.value
}

export function useSites() {
  if (!_loaded) refreshSites()
  return { sites, refreshSites }
}
