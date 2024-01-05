<script>
  export let data;
</script>

<h1><a href="/ui">DDBJ Repository</a></h1>

{#if data.me}
  <p>ID: {data.me.uid}</p>

  <form method="POST" action="/ui/session?/logout">
    <button>Logout</button>
  </form>
{/if}

<slot />
