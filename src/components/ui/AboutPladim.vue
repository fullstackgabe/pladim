<template>
  <button
    type="button"
    @click="open = true"
    :class="label
      ? 'inline-flex items-center gap-1.5 text-sm font-medium text-teal-600 hover:text-teal-700 transition-colors cursor-pointer'
      : 'p-2 rounded-lg text-teal-600 hover:bg-teal-50 transition-colors cursor-pointer'"
    aria-label="O que é Pladim?"
  >
    <Info class="w-5 h-5" />
    <span v-if="label">{{ label }}</span>
  </button>

  <Teleport to="body">
    <Transition name="modal">
      <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center p-4" @click.self="open = false">
        <div class="absolute inset-0 bg-black/30 backdrop-blur-sm" @click="open = false"></div>
        <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-md p-8">
          <button
            type="button"
            @click="open = false"
            class="absolute top-4 right-4 p-1 rounded-full text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors cursor-pointer"
            aria-label="Fechar"
          >
            <X class="w-5 h-5" />
          </button>

          <h2 class="text-2xl font-bold text-gray-900 tracking-tight">O que é <span class="text-teal-600">Pladim</span>?</h2>
          <p class="text-sm text-gray-500 mt-1 mb-6">Cada letra é um passo do método:</p>

          <ol class="space-y-4">
            <li v-for="step in STEPS" :key="step" class="flex items-start gap-3">
              <span class="w-9 h-9 shrink-0 rounded-lg bg-teal-600 text-white font-bold text-lg flex items-center justify-center">
                {{ step[0] }}
              </span>
              <p class="text-gray-700 leading-snug pt-1.5">
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
  'Pense em uma lista e coloque nela tudo o que precisa fazer',
  'Leia a sua missão, tenha sempre em mente seu objetivo/meta',
  'Assinale as prioridades, as coisas mais importantes para fazer',
  'Distribua na semana, não deixando tudo pra última hora',
  'Imprevistos você terá, deixe um tempo livre para eles',
  'Mentalize e tenha sempre em vista aquilo que planejou e saiba exatamente o que fazer',
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
