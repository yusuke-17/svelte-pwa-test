<script lang="ts">
  import TodoList from './components/TodoList.svelte';

  let appTitle = 'Svelte PWA Todo';
</script>

<main class="mx-auto max-w-2xl px-5 py-20 sm:px-2.5 sm:py-10">
  <header class="mb-8 text-center">
    <h1 class="m-0 text-5xl text-white drop-shadow-md sm:text-4xl">{appTitle}</h1>
  </header>
  <TodoList />
</main>
