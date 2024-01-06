<script>
  import { base } from '$app/paths';

  export let data;
</script>

<h1 class="display-6 mb-4">Requests</h1>

<table class="table">
  <thead>
    <tr>
      <th>ID</th>
      <th>Created</th>
      <th>Purpose</th>
      <th>DB</th>
      <th>Status</th>
      <th>Validity</th>
      <th>Submission</th>
    </tr>
  </thead>

  <tbody>
    {#each data.responses as res}
      <tr>
        <td>
          <a href="{base}/request/{res.id}">{res.id}</a>
        </td>

        <td>{res.created_at}</td>
        <td>{res.purpose}</td>
        <td>{res.db}</td>
        <td>{res.status}</td>

        <td>
          <span
            class="badge"
            class:text-bg-success={res.validity === 'valid'}
            class:text-bg-danger={res.validity === 'invalid'}
            class:text-bg-secondary={res.validity === 'error'}
          >
            {res.validity}
          </span>
        </td>

        <td>
          {#if res.submission}
            {res.submission.id}
          {/if}
        </td>
      </tr>
    {/each}
  </tbody>
</table>
