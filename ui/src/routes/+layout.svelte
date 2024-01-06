<script>
  import { onMount } from 'svelte';

  import '../app.scss';
  import { page } from '$app/stores';

  export let data;

  onMount(() => {
    import('bootstrap');
  });
</script>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="/ui">DDBJ Repository</a>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link" href="/ui/submit" class:active={$page.url.pathname === '/ui/submit/'}>Submit</a>
        </li>

        <li class="nav-item">
          <a
            class="nav-link"
            href="/ui/requests"
            class:active={$page.url.pathname === '/ui/requests/' || $page.url.pathname.startsWith('/ui/request/')}
          >
            Requests
          </a>
        </li>
      </ul>

      {#if data.me}
        <ul class="navbar-nav">
          <li class="nav-item dropdown">
            <button class="nav-link dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
              {data.me.uid}
            </button>

            <ul class="dropdown-menu">
              <li>
                <form method="POST" action="/ui/session?/logout">
                  <button class="dropdown-item">Logout</button>
                </form>
              </li>
            </ul>
          </li>
        </ul>
      {/if}
    </div>
  </div>
</nav>

<main class="container py-4">
  <slot />
</main>
