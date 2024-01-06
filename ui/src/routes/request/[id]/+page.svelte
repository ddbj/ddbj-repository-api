<script lang="ts">
  import ValidityBadge from '$lib/ValidityBadge.svelte';
  import { base } from '$app/paths';

  export let data;

  const request = data.request;
</script>

<h1 class="display-6 mb-4">Request #{request.id}</h1>

<div class="mb-3">
  <a href="{base}/requests">&laquo; Back</a>
</div>

<dl>
  <div>
    <dt>ID</dt>
    <dd>{request.id}</dd>
  </div>

  <div>
    <dt>Created</dt>
    <dd>{request.created_at}</dd>
  </div>

  <div>
    <dt>Purpose</dt>
    <dd>{request.purpose}</dd>
  </div>

  <div>
    <dt>DB</dt>
    <dd>{request.db}</dd>
  </div>

  <div>
    <dt>Status</dt>
    <dd>{request.status}</dd>
  </div>

  <div>
    <dt>Validity</dt>
    <dd><ValidityBadge validity={request.validity} /></dd>
  </div>

  <div>
    <dt>Submission</dt>

    <dd>
      {#if request.submission}
        {request.submission.id}
      {:else}
        -
      {/if}
    </dd>
  </div>
</dl>

<h2>Objects</h2>

<table class="table">
  <thead>
    <tr>
      <th>ID</th>
      <th>Files</th>
    </tr>
  </thead>

  <tbody>
    {#each request.objects as obj}
      <tr>
        <td>{obj.id}</td>

        <td>
          <ul class="mb-0">
            {#each obj.files as file}
              <li>{file.path}</li>
            {/each}
          </ul>
        </td>
      </tr>
    {/each}
  </tbody>
</table>

<h2>Validation Reports</h2>

<table class="table">
  <thead>
    <tr>
      <th>Object</th>
      <th>File</th>
      <th>Validity</th>
      <th>Details</th>
    </tr>
  </thead>

  <tbody>
    {#each request.validation_reports as report}
      <tr>
        <td>{report.object_id}</td>
        <td>{report.path}</td>

        <td>
          <ValidityBadge validity={report.validity} />
        </td>

        <td>
          <pre class="mb-0 py-1"><code>{JSON.stringify(report.details, null, 2)}</code></pre>
        </td>
      </tr>
    {/each}
  </tbody>
</table>

<style>
  dl {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 1rem 2rem;
  }

  pre {
    white-space: pre-wrap;
  }
</style>
