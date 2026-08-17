<template>
  <div class="fixed top-4 right-4 z-50 flex flex-col gap-2">
    <TransitionGroup name="toast">
      <div
        v-for="toast in toasts"
        :key="toast.id"
        class="flex items-center w-full max-w-xs p-4 rounded-lg shadow-md transition-all duration-300"
        role="alert"
        :class="{
          'bg-green-100 text-green-800': toast.type === 'success',
          'bg-red-100 text-red-800': toast.type === 'error',
          'bg-blue-100 text-blue-800': toast.type === 'info',
          'bg-yellow-100 text-yellow-800': toast.type === 'warning'
        }"
      >
        <div class="inline-flex items-center justify-center shrink-0 w-8 h-8 rounded-lg"
          :class="{
            'bg-green-200 text-green-700': toast.type === 'success',
            'bg-red-200 text-red-700': toast.type === 'error',
            'bg-blue-200 text-blue-700': toast.type === 'info',
            'bg-yellow-200 text-yellow-700': toast.type === 'warning'
          }"
        >
          <Check v-if="toast.type === 'success'" class="w-5 h-5" />
          <X v-else-if="toast.type === 'error'" class="w-5 h-5" />
          <Info v-else-if="toast.type === 'info'" class="w-5 h-5" />
          <AlertTriangle v-else-if="toast.type === 'warning'" class="w-5 h-5" />
        </div>
        <div class="ml-3 text-sm font-normal">
          <div class="font-bold" v-if="toast.title">{{ toast.title }}</div>
          <div v-if="toast.message" class="opacity-90">{{ toast.message }}</div>
        </div>
        <button 
          @click="removeToast(toast.id)" 
          type="button" 
          class="ml-auto -mx-1.5 -my-1.5 rounded-lg p-1.5 inline-flex h-8 w-8 focus:ring-2 cursor-pointer transition-colors"
          :class="{
            'text-green-600 hover:bg-green-200 focus:ring-green-300': toast.type === 'success',
            'text-red-600 hover:bg-red-200 focus:ring-red-300': toast.type === 'error',
            'text-blue-600 hover:bg-blue-200 focus:ring-blue-300': toast.type === 'info',
            'text-yellow-600 hover:bg-yellow-200 focus:ring-yellow-300': toast.type === 'warning'
          }"
          aria-label="Close"
        >
          <span class="sr-only">Close</span>
          <X class="w-4 h-4" />
        </button>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup lang="ts">
import { Check, X, Info, AlertTriangle } from 'lucide-vue-next'

const { toasts, remove } = useToast()

const removeToast = (id: string) => {
  remove(id)
}
</script>

<script lang="ts">
import { ref } from 'vue'

export interface ToastMessage {
  id: string
  title: string
  message?: string
  type: 'success' | 'error' | 'info' | 'warning'
  duration?: number
}

const globalToasts = ref<ToastMessage[]>([])

export function useToast() {
  const add = (toast: Omit<ToastMessage, 'id'>) => {
    const id = Date.now().toString(36) + Math.random().toString(36).substr(2)
    const newToast: ToastMessage = {
      id,
      duration: 3000,
      ...toast
    }
    
    globalToasts.value.push(newToast)

    if (newToast.duration) {
      setTimeout(() => {
        remove(id)
      }, newToast.duration)
    }
  }

  const remove = (id: string) => {
    const index = globalToasts.value.findIndex(t => t.id === id)
    if (index !== -1) {
      globalToasts.value.splice(index, 1)
    }
  }

  return {
    toasts: globalToasts,
    add,
    remove
  }
}
</script>


<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateX(30px);
}
</style>