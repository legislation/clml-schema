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

## Where this workflow lives

Currently, the `build-docs.yml` workflow is only present in the `feature/clml-schema-docs` branch on Github. This allows us to independently commit and test changes to the workflow and also mirror all branches from the source CLML schema Git repository in Bitbucket exactly as they originally appear. GitHub does suggest that users may have a separate branch for use with GitHub Pages (see [Configuring a publishing source for your GitHub Pages site](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)), so this approach is fairly similar to the standard recommendation for Pages deployment.

However, GitHub Actions will only run the workflow when a user pushes changes to a branch that contains the workflow, in this case the `feature/clml-schema-docs` branch. This is acceptable, as we can merge changes from the `main` branch into the `feature/clml-schema-docs` branch whenever we want to regenerate the documentation. It is also possible to create new branches off `feature/clml-schema-docs`: these will also contain the `build-docs.yml` workflow file, and so pushing changes to them will also trigger a build of the documentation, allowing for TNA to test changes to the documentation build process before merging changes into the main documentation branch.

## How to run the workflow

Follow the below steps to run the workflow.

 1. If you don’t already have the schema repository on your local machine, clone the `tna.legislation.schema.clml` from Bitbucket. You will need to request access. You should clone into a directory on your `C:` drive (e.g. `C:\temp`) as this will be much faster.
 2. If you do already have the schema repository on your local machine, make sure you are on the main branch (`git checkout main`, if you've any outstanding changes run `git stash` first).
 3. If you’ve not added the GitHub mirror repository as a remote, run `git remote add gh https://github.com/legislation/clml-schema.git` to add it.
 4. Run `git fetch --all` to fetch any new changes from Bitbucket and GitHub.
 5. Ensuring you are still on the `main` branch, run `git pull` to pull the latest changes into that branch.
 5. Run `git checkout feature/clml-schema-docs` to switch to the CLML documentation branch.
 6. Run `git merge main` to merge in any changes on the `main` branch to the `feature/clml-schema-docs` branch.
 7. If you want to make changes to the `build-docs.yml` file, ensure you save them and run `git add .github/workflows/build-docs.yml` then `git commit -m "[COMMIT MESSAGE]"`, replacing `[COMMIT MESSAGE]` with a suitably descriptive message explaining your changes.
 8. Run `git push gh` to push any changes now present in the `feature/clml-schema-docs` branch to GitHub.
 9. GitHub Actions will run the workflow automatically. You can follow its progress at https://github.com/legislation/clml-schema/actions.

## Things that may break in future

 * You must configure a repository secret called `OXYGEN_LICENCE_KEY` (note that `LICENCE` is spelled with a `C`, not an `S`) that contains a full, 9-line oXygen Scripting licence key. Instructions on how to do this are above.
 * The workflow depends on the presence of the availability of an oXygen XML v25.1 distribution at `https://archives.oxygenxml.com/Oxygen/Editor/InstData25.1/All/oxygen.tar.gz`. If SyncRO Soft stop providing this file at that address, or start requiring a login to download it, you will need to adapt the workflow to download the file from another location, such as a public S3 bucket that we control. (That `oxygen.tar.gz` file is available in SharePoint and can be found via search.)
 * GitHub may deprecate or remove some of the actions we use in the workflow, in which case you will need to replace them with different actions. (As all of the actions are official GitHub actions, hopefully this is unlikely.)
