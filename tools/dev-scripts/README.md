# Dev workflow scripts

These assume the layout used on the primary dev machine:

```
H:\URDU\StandaloneApp\            <- editable source (team.html, tests.html, js/, css/, supabase/, ...)
H:\URDU\StandaloneApp\github-deploy\   <- this git clone (mediafocolarepak/Urdu-Archive)
```

On a new machine: create `H:\URDU\StandaloneApp`, clone this repo into
`H:\URDU\StandaloneApp\github-deploy`, then run `_sync_from_deploy.ps1` (from inside
`H:\URDU\StandaloneApp`, after copying these three scripts there too) to reconstruct the
editable source from the deploy repo's last-published content. If your drive letter or path
differs, edit the `$root`/`$deploy` variables at the top of each script first.

- **publish.ps1** - copies source -> github-deploy (substituting the `?v=__V__` cache-buster
  placeholder with a real timestamp token), commits, and pushes.
- **_sync_from_deploy.ps1** - the reverse: rebuilds the editable source (with `__V__` restored)
  from whatever is currently committed in github-deploy. Use this once on a new machine, or any
  time the source folder gets out of sync with what's actually deployed.
- **_localserver.ps1** - a minimal static file server (`http://localhost:8899/`) for previewing
  the source folder directly (team.html, unsubstituted `__V__` in the URL is harmless) without
  publishing first.
