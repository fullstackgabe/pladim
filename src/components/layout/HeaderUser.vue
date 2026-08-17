<template>
  <header class="bg-white py-4 px-6 mb-8 flex items-center justify-between rounded-xl shadow-sm border border-gray-100">
    <button
      @click="showModal = true"
      class="flex items-center gap-3 cursor-pointer transform hover:scale-105 transition-transform duration-300 text-left"
    >
      <img
        v-if="user?.avatar && !imageError"
        :src="user.avatar"
        alt="Avatar"
        class="w-10 h-10 rounded-full border-2 border-white shadow-sm object-cover"
        referrerpolicy="no-referrer"
        @error="imageError = true"
      />
      <div v-else class="w-10 h-10 rounded-full bg-gray-200 border-2 border-white shadow-sm flex items-center justify-center text-gray-400">
        <UserIcon class="w-6 h-6" />
      </div>
      <div class="flex flex-col">
        <span class="font-bold text-gray-800 text-sm">{{ user?.name || 'Usuário' }}</span>
        <span class="text-xs text-gray-500">{{ user?.email }}</span>
      </div>
    </button>

    <button
      @click="$emit('logout')"
      class="px-4 py-1.5 text-sm font-medium text-red-500 border border-red-200 rounded-lg hover:bg-red-50 transition-colors cursor-pointer"
    >
      Sair
    </button>
  </header>

  <Teleport to="body">
    <Transition name="modal">
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4" @click.self="showModal = false">
        <div class="absolute inset-0 bg-black/30 backdrop-blur-sm" @click="showModal = false; confirmingReset = false"></div>
        <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-sm p-8 flex flex-col items-center gap-4">
          <template v-if="!confirmingReset">
            <img
              v-if="user?.avatar && !imageError"
              :src="user.avatar"
              alt="Avatar"
              class="w-20 h-20 rounded-full border-4 border-gray-100 shadow object-cover"
              referrerpolicy="no-referrer"
            />
            <div v-else class="w-20 h-20 rounded-full bg-gray-200 flex items-center justify-center text-gray-400">
              <UserIcon class="w-10 h-10" />
            </div>

            <div class="text-center">
              <p class="font-bold text-gray-800 text-lg">{{ user?.name || 'Usuário' }}</p>
              <p class="text-sm text-gray-500">{{ user?.email }}</p>
            </div>

            <button
              @click="confirmingReset = true"
              class="w-full py-2.5 text-sm font-medium text-red-500 border border-red-200 rounded-xl hover:bg-red-50 transition-colors cursor-pointer"
            >
              Limpar todos os dados
            </button>
          </template>

          <template v-else>
            <div class="text-center">
              <p class="font-bold text-gray-800 text-lg mb-2">Limpar todos os dados?</p>
              <p class="text-sm text-gray-500">Isso vai apagar todas as tarefas, recompensas, históricos e pontos. Essa ação não pode ser desfeita.</p>
            </div>

            <div class="w-full flex gap-3 mt-2">
              <button
                @click="confirmingReset = false"
                class="flex-1 py-2.5 text-sm font-medium text-gray-600 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors cursor-pointer"
              >
                Cancelar
              </button>
              <button
                @click="handleReset"
                class="flex-1 py-2.5 text-sm font-medium text-white bg-red-500 rounded-xl hover:bg-red-600 transition-colors cursor-pointer"
              >
                Confirmar
              </button>
            </div>
          </template>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { User as UserIcon } from 'lucide-vue-next'
import type { GoogleUser } from '@/types'

const props = defineProps<{
  user: GoogleUser | null
}>()

const emit = defineEmits<{
  (e: 'logout'): void
  (e: 'reset'): void
}>()

const imageError = ref(false)
const showModal = ref(false)
const confirmingReset = ref(false)

watch(() => props.user?.avatar, () => {
  imageError.value = false
})

const handleLogout = () => {
  showModal.value = false
  emit('logout')
}

const handleReset = () => {
  confirmingReset.value = false
  showModal.value = false
  emit('reset')
}
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
</style>
