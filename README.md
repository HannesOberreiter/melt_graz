# Melt-Curve Analysis

Basic melting curve analysis to differentiate two different taxon.

## Reproducibility

For full reproduciblity we include in this repository our data files. You can either use directly the github project and install the packages with renv or use the automatically generated docker file.

## Version Control

We are using renv for version control. 

## Docker

For reproducibility there is a automatically generated docker image from this repository `Dockerfile`. We decided to leverage the caching from renv and keep the docker compiling time at minimum. Because of this you have to define your local cache paths, please see official documentation [docker-renv](https://rstudio.github.io/renv/articles/docker.html#running-docker-containers-with-renv-1).

```r
Sys.setenv(RENV_PATHS_CACHE = "~/renv/cache")
renv:::renv_paths_cache()
```

### Docker Run

Find your local renv cache with `renv:::renv_paths_cache()`. The globals `DOCKER_LOKAL_FILES`, `MY_GIT_USER`, `MY_GIT_EMAIL` are all optional and can be left empty.

docker run -d -p 8787:8787 -e USER=yourName -e PASSWORD=secretPassword -e ROOT=TRUE -e GIT_USER="gitUsername" -e GIT_EMAIL="yourEmail@gmail.com" -e THEME="Solarized Dark"  rocker/tidyverse:3.4.3

```bash
RENV_PATHS_CACHE_HOST="/Users/virus-on-mac/Library/Application Support/renv/cache"
DOCKER_LOKAL_FILES="/Users/virus-on-mac/Reserve/Repos/hrm_graz"
MY_GIT_USER=""
MY_GIT_EMAIL=""
```

```bash
docker run --rm \
    -e ROOT=TRUE \
    -v "${RENV_PATHS_CACHE_HOST}:/home/rstudio/.local/share/renv/cache" \
    -v "${DOCKER_LOKAL_FILES}:/home/rstudio/lokal" \
    -e "GIT_EMAIL=${MY_GIT_EMAIL}" \
    -e "GIT_USER=${MY_GIT_USER}" \
    -p 8787:8787 \
    melt_graz
```

## MIT Licence

Copyright (c) 2020 Hannes Oberreiter
