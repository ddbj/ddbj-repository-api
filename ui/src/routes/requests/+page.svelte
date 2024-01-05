<script>
  export let data;
</script>

<h2>Requests</h2>
<table>
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
        <td><a href="/ui/request/{res.id}">{res.id}</a></td>
        <td>{res.created_at}</td>
        <td>{res.purpose}</td>
        <td>{res.db}</td>
        <td>{res.status}</td>
        <td>{res.validity}</td>
        <td>
          {#if res.submission}
            {res.submission.id}
          {/if}
        </td>
      </tr>
    {/each}
  </tbody>
</table>
