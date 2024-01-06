<h1 class="display-6 mb-4">Submit</h1>

<ul class="nav nav-tabs mb-3" role="tablist">
  <li class="nav-item" role="presentation">
    <button
      class="nav-link active"
      id="metabobank-tab"
      data-bs-toggle="tab"
      data-bs-target="#metabobank-pane"
      role="tab"
      aria-controls="metabobank-pane"
      aria-selected="true">MetaboBank</button
    >
  </li>
</ul>

<div class="tab-content">
  <div class="tab-pane fade show active" id="metabobank-pane" role="tabpanel" aria-labelledby="metabobank-tab" tabindex="0">
    <form method="POST" enctype="multipart/form-data">
      <fieldset>
        <legend>IDF</legend>

        <div class="mb-3">
          <label for="IDF[file]" class="form-label">File</label>
          <input type="file" name="IDF[file]" required id="IDF[file]" class="form-control" />
        </div>
      </fieldset>

      <fieldset>
        <legend>SDRF</legend>

        <div class="mb-3">
          <label for="SDRF[file]" class="form-label">File</label>
          <input type="file" name="SDRF[file]" required id="SDRF[file]" class="form-control" />
        </div>
      </fieldset>

      <div class="mt-3 d-flex gap-3 align-items-center">
        <div class="d-flex border rounded">
          <div class="px-3 py-1 border-end">
            <div class="form-check">
              <input type="radio" name="resource" required id="resource-validations" value="validations" class="form-check-input" />

              <label for="resource-validations" class="form-check-label"> Validate </label>
            </div>
          </div>

          <div class="px-3 py-1">
            <div class="form-check">
              <input type="radio" name="resource" required id="resource-submissions" value="submissions" class="form-check-input" />

              <label for="resource-submissions" class="form-check-label"> Submit </label>
            </div>
          </div>
        </div>

        <div>
          <button class="btn btn-primary">Execute</button>
        </div>
      </div>
    </form>
  </div>
</div>
