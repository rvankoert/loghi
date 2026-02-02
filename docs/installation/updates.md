# Updates

## Updating Loghi

It is recommended to update the entire Loghi repository in the following scenarios:
1. we release new features;
2. we add bug fixes;
3. you run into issues;
4. you download a new model.

To that end, run the following command:
```bash
git pull origin main
```

You might have made local edits to files like `scripts/inference-pipeline.sh`. [Here](../questions/troubleshooting) we provide a solution for you to keep the local changes while updating the repository. 
<!-- link to be updated -->

## Updating the submodules

Additionally, to stay updated with the latest versions of the submodules, run:

```bash
git submodule update --recursive --remote
```

This ensures you have access to the most recent (though possibly unstable) versions of the code.