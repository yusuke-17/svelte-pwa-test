<script lang="ts">
  interface Todo {
    id: number;
    text: string;
    completed: boolean;
  }

  interface Props {
    todo: Todo;
    onToggle: () => void;
    onDelete: () => void;
  }

  let { todo, onToggle, onDelete }: Props = $props();
</script>

<div
  class="flex items-center gap-3 rounded-lg bg-gray-50 p-4 transition-all hover:translate-x-1 hover:bg-gray-100"
  class:opacity-60={todo.completed}
>
  <label class="flex cursor-pointer items-center">
    <input type="checkbox" checked={todo.completed} onchange={onToggle} class="custom-checkbox" />
  </label>
  <span
    class="flex-1 text-base break-words text-gray-800"
    class:line-through={todo.completed}
    class:text-gray-400={todo.completed}
  >
    {todo.text}
  </span>
  <button
    onclick={onDelete}
    class="bg-danger flex h-8 w-8 flex-shrink-0 cursor-pointer items-center justify-center rounded-md border-0 text-lg text-white transition-all hover:scale-110 hover:bg-red-600 active:scale-95"
    aria-label="削除"
  >
    ✕
  </button>
</div>
