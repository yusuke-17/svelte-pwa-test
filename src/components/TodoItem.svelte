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

<div class="todo-item" class:completed={todo.completed}>
  <label class="checkbox-wrapper">
    <input type="checkbox" checked={todo.completed} onchange={onToggle} />
    <span class="checkmark"></span>
  </label>
  <span class="todo-text">{todo.text}</span>
  <button onclick={onDelete} class="delete-btn" aria-label="削除"> ✕ </button>
</div>

<style>
  .todo-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    transition: all 0.3s;
  }

  .todo-item:hover {
    background: #f0f1f3;
    transform: translateX(5px);
  }

  .todo-item.completed {
    opacity: 0.6;
  }

  .checkbox-wrapper {
    position: relative;
    cursor: pointer;
    display: flex;
    align-items: center;
  }

  .checkbox-wrapper input {
    opacity: 0;
    position: absolute;
    cursor: pointer;
  }

  .checkmark {
    width: 24px;
    height: 24px;
    border: 2px solid #667eea;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s;
  }

  .checkbox-wrapper input:checked ~ .checkmark {
    background: #667eea;
  }

  .checkbox-wrapper input:checked ~ .checkmark::after {
    content: '✓';
    color: white;
    font-size: 16px;
    font-weight: bold;
  }

  .todo-text {
    flex: 1;
    font-size: 16px;
    color: #333;
    word-break: break-word;
  }

  .completed .todo-text {
    text-decoration: line-through;
    color: #999;
  }

  .delete-btn {
    width: 32px;
    height: 32px;
    border: none;
    background: #ff4757;
    color: white;
    border-radius: 6px;
    cursor: pointer;
    font-size: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    flex-shrink: 0;
  }

  .delete-btn:hover {
    background: #ff3838;
    transform: scale(1.1);
  }

  .delete-btn:active {
    transform: scale(0.95);
  }
</style>
