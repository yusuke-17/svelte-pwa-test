<script lang="ts">
  import { onMount } from "svelte";
  import TodoItem from "./TodoItem.svelte";

  interface Todo {
    id: number;
    text: string;
    completed: boolean;
  }

  let todos = $state<Todo[]>([]);
  let newTodoText = $state("");

  const STORAGE_KEY = "svelte-pwa-todos";

  onMount(() => {
    loadTodos();
  });

  function loadTodos() {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        todos = JSON.parse(stored);
      } catch (e) {
        console.error("Failed to load todos:", e);
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
      newTodoText = "";
      saveTodos();
    }
  }

  function toggleTodo(id: number) {
    todos = todos.map((todo) =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    );
    saveTodos();
  }

  function deleteTodo(id: number) {
    todos = todos.filter((todo) => todo.id !== id);
    saveTodos();
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === "Enter") {
      addTodo();
    }
  }
</script>

<div class="todo-container">
  <div class="input-group">
    <input
      type="text"
      bind:value={newTodoText}
      onkeydown={handleKeydown}
      placeholder="新しいタスクを入力..."
      class="todo-input"
    />
    <button onclick={addTodo} class="add-btn">追加</button>
  </div>

  <div class="todo-list">
    {#if todos.length === 0}
      <p class="empty-message">
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

<style>
  .todo-container {
    background: white;
    border-radius: 12px;
    padding: 25px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  }

  .input-group {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
  }

  .todo-input {
    flex: 1;
    padding: 12px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 16px;
    transition: border-color 0.3s;
  }

  .todo-input:focus {
    outline: none;
    border-color: #667eea;
  }

  .add-btn {
    padding: 12px 25px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition:
      transform 0.2s,
      box-shadow 0.2s;
  }

  .add-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
  }

  .add-btn:active {
    transform: translateY(0);
  }

  .todo-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .empty-message {
    text-align: center;
    color: #999;
    padding: 40px 20px;
    font-size: 16px;
  }

  @media (max-width: 600px) {
    .todo-container {
      padding: 15px;
    }

    .input-group {
      flex-direction: column;
    }

    .add-btn {
      width: 100%;
    }
  }
</style>
