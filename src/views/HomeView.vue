<template>
  <div class="relative flex items-center justify-center min-h-screen overflow-hidden bg-gradient-to-br from-teal-50 via-white to-emerald-50">
    <div class="pointer-events-none absolute -top-24 -left-24 w-80 h-80 rounded-full bg-teal-200/60 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-32 -right-24 w-96 h-96 rounded-full bg-emerald-200/60 blur-3xl"></div>
    <div class="pointer-events-none absolute top-1/4 right-1/4 w-56 h-56 rounded-full bg-yellow-100/70 blur-3xl"></div>
    <div class="relative bg-white p-12 rounded-2xl shadow-2xl shadow-gray-900/25 ring-1 ring-gray-100 max-w-md w-full text-center mx-4">
      <h1 class="text-4xl font-bold mb-3 text-[#1a202c] tracking-tight">Pladim.</h1>
      <div class="mb-10">
        <AboutPladim label="O que é Pladim?" />
      </div>
      <button
        @click="loginWithGoogle"
        :disabled="loading"
        class="w-full flex items-center justify-center gap-3 px-6 py-3 border border-gray-300 rounded-lg bg-white hover:bg-gray-50 transition-colors text-gray-700 font-medium text-base cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <svg v-if="!loading" width="20" height="20" viewBox="0 0 48 48">
          <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
          <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
          <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
          <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.36-8.16 2.36-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
        </svg>
        <span v-if="loading" class="w-5 h-5 border-2 border-gray-300 border-t-gray-600 rounded-full animate-spin"></span>
        {{ loading ? 'Entrando...' : 'Entrar com Google' }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '@/services/supabase'
import { useToast } from '@/components/ui/ToastContainer.vue'
import AboutPladim from '@/components/ui/AboutPladim.vue'

const loading = ref(false)
const { add: addToast } = useToast()

const loginWithGoogle = async () => {
  loading.value = true
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin,
      },
    })
    if (error) throw error
  } catch {
    loading.value = false
    addToast({
      title: 'Erro de Autenticação',
      message: 'Não foi possível autenticar com o Google.',
      type: 'error',
    })
  }
}
</script>
