# Updates

## Updating Loghi

It is recommended to update the entire Loghi repository in the following scenarios:
1. We release new features;
2. We add bug fixes;
3. You run into issues.

To that end, run the following command:
```bash
git pull origin main
```

:::{note}
If you have made local edits to files like `scripts/inference-pipeline.sh`, you can preserve your changes while updating:

```bash
git stash                # Temporarily stores local changes
git pull origin main
git stash pop            # Restores local changes
```

If there are conflicts between your changes and the update, Git will notify you and you'll need to resolve them manually.
:::

## Updating the Submodules

Additionally, to stay updated with the latest versions of the submodules, run:

```bash
git submodule update --recursive --remote
```

:::{caution}
The `--remote` flag fetches the most recent versions of the code, which may include unstable changes.
:::