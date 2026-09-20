<template>
  <div v-bind="$attrs" class="relative overflow-hidden bg-gradient-to-br from-teal-50 via-white to-emerald-50 border border-teal-100 rounded-2xl shadow-sm px-6 py-4 flex flex-col justify-center min-h-[96px]">
    <div class="pointer-events-none absolute -top-16 -right-10 w-48 h-48 rounded-full bg-teal-200/50 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-20 left-1/3 w-56 h-56 rounded-full bg-emerald-200/50 blur-3xl"></div>
    <button
      type="button"
      @click="openEditor"
      class="absolute top-3 right-3 p-2 rounded-lg text-gray-400 hover:text-teal-700 hover:bg-teal-50 transition-colors cursor-pointer"
      :aria-label="goal ? 'Editar missão' : 'Definir missão'"
    >
      <Pencil class="w-4 h-4" />
    </button>
    <span class="relative flex items-center gap-1.5 text-teal-600 text-xs font-bold uppercase tracking-widest">
      <Target class="w-4 h-4" />
      Minha missão
    </span>
    <p v-if="goal" class="relative mt-1 text-lg font-semibold leading-snug pr-8 whitespace-pre-line text-gray-800">{{ goal }}</p>
    <button
      v-else
      type="button"
      @click="openEditor"
      class="relative mt-1 text-left text-gray-500 text-base pr-8 cursor-pointer hover:text-teal-700 transition-colors"
    >
      Defina a sua missão e deixe ela sempre à vista.
    </button>
  </div>

  <Teleport to="body">
    <Transition name="modal">
      <div v-if="editing" class="fixed inset-0 z-50 flex items-center justify-center p-4" @click.self="editing = false">
        <div class="absolute inset-0 bg-black/30 backdrop-blur-sm" @click="editing = false"></div>
        <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-md p-8">
          <h2 class="text-xl font-bold text-gray-900 mb-1">Minha missão</h2>
          <p class="text-sm text-gray-500 mb-4">Escreva a sua missão e tenha sempre em mente o seu objetivo.</p>
          <textarea
            ref="input"
            v-model="draft"
            rows="3"
            maxlength="100"
            placeholder="Ex.: Passar no concurso até dezembro"
            class="w-full border border-gray-300 rounded-xl px-4 py-3 text-gray-800 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 resize-none"
          ></textarea>
          <div class="flex justify-between items-center mt-1">
            <span class="text-xs text-gray-400">{{ draft.length }}/100</span>
          </div>
          <div class="flex gap-3 mt-4">
            <button
              type="button"
              @click="editing = false"
              class="flex-1 py-2.5 text-sm font-medium text-gray-600 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors cursor-pointer"
            >
              Cancelar
            </button>
            <button
              type="button"
              @click="save"
              :disabled="saving"
              class="flex-1 py-2.5 text-sm font-medium text-white bg-teal-600 rounded-xl hover:bg-teal-700 transition-colors cursor-pointer disabled:opacity-50"
            >
              Salvar
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { nextTick, ref } from 'vue'
import { Pencil, Target } from 'lucide-vue-next'

defineOptions({ inheritAttrs: false })

const props = defineProps<{ goal: string }>()
const emit = defineEmits<{ (e: 'save', goal: string): void }>()

const editing = ref(false)
const saving = ref(false)
const draft = ref('')
const input = ref<HTMLTextAreaElement | null>(null)

const openEditor = async () => {
  draft.value = props.goal
  editing.value = true
  await nextTick()
  input.value?.focus()
}

const save = () => {
  emit('save', draft.value.trim().slice(0, 100))
  editing.value = false
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
