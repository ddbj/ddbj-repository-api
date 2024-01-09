<script lang="ts">
  import { PUBLIC_API_URL } from '$env/static/public';

  const loginUrl = new URL('/auth/login', PUBLIC_API_URL).href;
</script>

<div class="card mx-auto" style="width: 32rem">
  <div class="card-body">
    <form method="POST">
      <div class="mb-3">
        <label for="apiKey" class="form-label">API key</label>
        <input type="text" name="apiKey" id="apiKey" class="form-control" />
      </div>

      <button class="btn btn-primary mb-3">Login</button>

      <p class="mb-0">
        <a href={loginUrl} target="_blank"> Your API key can be obtained here. </a>
      </p>
    </form>
  </div>
</div>
