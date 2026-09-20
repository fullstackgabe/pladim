<template>
  <button
    type="button"
    @click="open = true"
    :class="label
      ? 'inline-flex items-center gap-1.5 text-sm font-medium text-teal-900 hover:text-teal-700 transition-colors cursor-pointer'
      : 'p-2 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors cursor-pointer'"
    aria-label="O que é Pladim?"
  >
    <Info class="w-5 h-5" />
    <span v-if="label">{{ label }}</span>
  </button>

  <Teleport to="body">
    <Transition name="modal">
      <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center p-6" @click.self="open = false">
        <div class="absolute inset-0 bg-black/30 backdrop-blur-sm" @click="open = false"></div>
        <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-md p-6 sm:p-7 max-h-[calc(100vh-3rem)] overflow-y-auto">
          <button
            type="button"
            @click="open = false"
            class="absolute top-4 right-4 p-1 rounded-full text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors cursor-pointer"
            aria-label="Fechar"
          >
            <X class="w-5 h-5" />
          </button>

          <h2 class="text-xl font-bold text-gray-900 tracking-tight">O que é <span class="text-teal-600">Pladim</span>?</h2>
          <p class="text-xs text-gray-500 mt-1 mb-5">Cada letra é um passo do método:</p>

          <ol class="space-y-3">
            <li v-for="step in STEPS" :key="step" class="flex items-center gap-3">
              <span class="w-8 h-8 shrink-0 rounded-lg bg-teal-600 text-white font-bold text-base flex items-center justify-center">
                {{ step[0] }}
              </span>
              <p class="text-[13px] text-gray-700 leading-4">
                <span class="font-bold text-teal-700">{{ step[0] }}</span>{{ step.slice(1) }}
              </p>
            </li>
          </ol>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Info, X } from 'lucide-vue-next'

defineProps<{ label?: string }>()

const open = ref(false)

const STEPS = [
  'Pense numa lista de tarefas que te leva ao objetivo.',
  'Leia a sua missão todos os dias até alcançar seu objetivo.',
  'Assinale como prioridade o que é mais importante naquele dia.',
  'Distribua as tarefas na semana e não deixe nada de fora.',
  'Imprevistos acontecem, reserve um dia para eles.',
  'Mentalize todos os dias como vai ser quando alcançar sua meta.',
]
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
