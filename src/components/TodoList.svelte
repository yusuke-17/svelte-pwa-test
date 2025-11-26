<script lang="ts">
  import { onMount } from 'svelte';
  import TodoItem from './TodoItem.svelte';

  interface Todo {
    id: number;
    text: string;
    completed: boolean;
  }

  let todos = $state<Todo[]>([]);
  let newTodoText = $state('');

  const STORAGE_KEY = 'svelte-pwa-todos';

  onMount(() => {
    loadTodos();
  });

  function loadTodos() {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        todos = JSON.parse(stored);
      } catch (e) {
        console.error('Failed to load todos:', e);
        todos = [];
      }
    }
  }

  function saveTodos() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
  }

  function addTodo() {
    if (newTodoText.trim()) {
      todos = [
        ...todos,
        {
          id: Date.now(),
          text: newTodoText.trim(),
          completed: false,
        },
      ];
      newTodoText = '';
      saveTodos();
    }
  }

  function toggleTodo(id: number) {
    todos = todos.map((todo) => (todo.id === id ? { ...todo, completed: !todo.completed } : todo));
    saveTodos();
  }

  function deleteTodo(id: number) {
    todos = todos.filter((todo) => todo.id !== id);
    saveTodos();
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      addTodo();
    }
  }
</script>

<div class="rounded-xl bg-white p-6 shadow-2xl sm:p-4">
  <div class="mb-5 flex gap-2.5 sm:flex-col">
    <input
      type="text"
      bind:value={newTodoText}
      onkeydown={handleKeydown}
      placeholder="新しいタスクを入力..."
      class="focus:border-primary flex-1 rounded-lg border-2 border-gray-200 px-4 py-3 text-base transition-colors focus:outline-none"
    />
    <button
      onclick={addTodo}
      class="from-primary to-secondary cursor-pointer rounded-lg border-0 bg-gradient-to-br px-6 py-3 text-base font-semibold text-white transition-all hover:-translate-y-0.5 hover:shadow-lg active:translate-y-0 sm:w-full"
    >
      追加
    </button>
  </div>

  <div class="flex flex-col gap-2.5">
    {#if todos.length === 0}
      <p class="px-5 py-10 text-center text-base text-gray-400">
        タスクがありません。新しいタスクを追加してください。
      </p>
    {:else}
      {#each todos as todo (todo.id)}
        <TodoItem
          {todo}
          onToggle={() => toggleTodo(todo.id)}
          onDelete={() => deleteTodo(todo.id)}
        />
      {/each}
    {/if}
  </div>
</div>
