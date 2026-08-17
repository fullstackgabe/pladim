<script setup lang="ts">
import { onMounted } from 'vue'
import ToastContainer from '@/components/ui/ToastContainer.vue'
import HomeView from '@/views/HomeView.vue'
import DashboardView from '@/views/DashboardView.vue'
import { supabase } from '@/services/supabase'
import { usePladimStore } from '@/stores/pladim'

const store = usePladimStore()

onMounted(async () => {
  await store.checkSession()
  if (window.location.hash) {
    window.history.replaceState(null, '', window.location.pathname)
  }

  supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_IN' && session && !store.userId) {
      await store.handleSession(session)
      if (!store.authReady) store.authReady = true
    } else if (event === 'SIGNED_OUT') {
      store.$reset()
      store.authReady = true
    }
  })
})
</script>

<template>
  <Transition name="fade" mode="out-in">
    <div v-if="!store.authReady" key="loading" class="flex items-center justify-center min-h-screen bg-gray-50">
      <div class="w-8 h-8 border-2 border-gray-300 border-t-gray-700 rounded-full animate-spin"></div>
    </div>
    <DashboardView v-else-if="store.userId" key="dashboard" />
    <HomeView v-else key="home" />
  </Transition>
  <ToastContainer />
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
