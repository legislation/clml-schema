# CLML Schema Documentation automated build workflow

## Summary

The `build-docs.yml` file in this directory is a [GitHub Actions](https://docs.github.com/en/actions) workflow that builds the HTML documentation for the CLML schema.

The workflow will run whenever any user pushes changes to any branch on GitHub that contains the file `.github/workflows/build-docs.yml`. (The workflow specifies this using the directive `on: push`. For more information on workflow triggers, see [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows).)

The workflow runs the following steps:
  1. Check that there is a [repository secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) called `OXYGEN_LICENCE_KEY` that contains a valid licence key for [oXygen Scripting](https://www.oxygenxml.com/oxygen_scripting.html) (which we require to run the documentation generator). If the secret is not configured, you can set it up at https://github.com/legislation/clml-schema/settings/secrets/actions.
  2. Set up Java 17 so the job can run oXygen.
  3. Download oXygen Scripting v25.1, the latest available version that our current licence key supports.
  4. Extract oXygen Scripting from the downloaded archive. 
  5. Install the oXygen licence key.
  6. Check out the CLML schema repository (at the current branch and commit).
  7. Check out the CLML schema documentation generator repository (at the time of writing, this uses the `feature/tna-enhancements` branch, which contains necessary code changes to build the latest documentation).
  8. Configure the transformation scenario settings file to point to the correct directories for this job.
  9. Run the schema documentation generator.
  10. Package up the contents of the `finalOutput/` output folder and upload it as an “artifact” that the Pages deployment step can use.
  11. Deploy the artifact from the previous step to GitHub Pages (at https://legislation.github.io/clml-schema/).