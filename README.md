# Melt-Curve Analysis

Basic melting curve analysis in R to differentiate two taxa.

## Reproducibility

For full reproducibility we include in this repository our data files and a dockerfile including the raw code. You can either use directly the github project and install the packages by yourself or use the automatically generated docker file.

### Docker

For reproducibility there is a automatically generated docker image from this repository `Dockerfile`.

### Docker Run

The globals `DOCKER_LOKAL_FILES`, `MY_GIT_USER`, `MY_GIT_EMAIL` are all optional and can be left empty.

```bash
DOCKER_LOKAL_FILES="path/to/lokal/folder"
MY_GIT_USER=""
MY_GIT_EMAIL=""
```

```bash
docker run --rm \
    -v "${DOCKER_LOKAL_FILES}:/home/rstudio/lokal" \
    -e "GIT_EMAIL=${MY_GIT_EMAIL}" \
    -e "GIT_USER=${MY_GIT_USER}" \
    -p 8787:8787 \
    hannesoberreiter/melt_graz
```

## MIT Licence

Copyright (c) 2020 Hannes Oberreiter

## Publications

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3872699.svg)](https://doi.org/10.5281/zenodo.3872699)
