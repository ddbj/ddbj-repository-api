<script lang="ts">
  export let validity: string;

  const klass =
    validity === 'valid'
      ? 'text-bg-success'
      : validity === 'invalid'
        ? 'text-bg-danger'
        : validity === 'error'
          ? 'text-bg-warning'
          : 'text-bg-secondary';
</script>

<span class="badge {klass}">{validity}</span>

<style>
  span {
    text-transform: capitalize;
  }
</style>
