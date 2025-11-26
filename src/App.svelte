<script lang="ts">
  import TodoList from './components/TodoList.svelte';

  let appTitle = 'Svelte PWA Todo';
</script>

<main>
  <header>
    <h1>{appTitle}</h1>
  </header>
  <TodoList />
</main>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family:
      -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
  }

  main {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
  }

  header {
    text-align: center;
    margin-bottom: 30px;
  }

  h1 {
    color: white;
    font-size: 2.5rem;
    margin: 0;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
  }

  @media (max-width: 600px) {
    main {
      padding: 10px;
    }

    h1 {
      font-size: 2rem;
    }
  }
</style>
