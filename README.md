# Mittwald's Kubernetes Helm Charts

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Release Charts](https://github.com/mittwald/helm-charts/workflows/Release%20Charts/badge.svg)

## Usage

[Helm](https://helm.sh) must be installed.
Refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once you've set up Helm properly, add this repository as follows:

```shell
$ helm repo add mittwald https://helm.mittwald.de
"mittwald" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "mittwald" chart repository
Update Complete. ⎈ Happy Helming!⎈

$ helm search repo mittwald
NAME                          	CHART VERSION	APP VERSION 	DESCRIPTION
[...]
```

## Contributing

### Adding new Charts

In order to add a new chart to this repository, add the desired repository and the corresponding chart-path to [upstream_charts.json](./conf.d/upstream_charts.json).  
On push to the `master`-branch the [release workflow](./.github/workflows/release.yml) will automagically update the charts.

### Updating Charts

Unfortunately Github-Workflows are not capable of getting triggered manually.  
Therefore, the `release`-workflow is triggered on schedule every 15th minute: `*/15 * * * *`

In case you need an immediate update of the charts in this repository, this `curl` is for you:

```shell
curl -X POST 'https://api.github.com/repos/mittwald/helm-charts/dispatches' \
-u ${GITHUB_USERNAME}:${GITHUB_PASSWORD_OR_API_KEY} \
-d '{"event_type": "updateCharts"}'
```

### Regenerate Charts

In case the generator fails for some reason and the "chart-update-commit" is
already superseded by a newer one, it won't generate the chart again.

However, this can also be done manually:

```sh
# clone the repo
git clone https://github.com/mittwald/helm-charts
cd helm-charts

cr package charts/CHART_NAME

# COMMIT_HASH is the commit the release will be created for
cr upload -c COMMIT_HASH -r helm-charts --owner mittwald --token YOUR_GITHUB_TOKEN

git checkout gh-pages

# make sure the packages chart is still stored in ./.cr-release-packages
# it may be wise do a dry run without `--token` first
cr index -r helm-charts -c https://helm.mittwald.de --owner mittwald --pages-branch gh-pages --index-path index.yaml --push --token YOUR_GITHUB_TOKEN
```

## License

[MIT](./LICENSE)
