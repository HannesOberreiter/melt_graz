# Melt-Curve Analysis

Basic melting curve analysis to differentiate two different taxon.

## Reproducibility

For full reproduciblity we include in this repository our data files. You can either use directly the github project and install the packages with renv or use the automatically generated docker file.

## Version Control

We are using renv for version control. 

## Docker

For reproducibility there is a automatically generated docker image from this repository `Dockerfile`. We decided to leverage the caching from renv and keep the docker compiling time at minimun. Because of this you have to define your local cache paths, please see official documentation [docker-renv](https://rstudio.github.io/renv/articles/docker.html#running-docker-containers-with-renv-1).


Sys.setenv(RENV_PATHS_CACHE = "~/renv/cache")
renv:::renv_paths_cache()


### Docker Run

Find your local renv cache with `renv:::renv_paths_cache()`.

```bash
RENV_PATHS_CACHE_HOST="/Users/virus-on-mac/Library/Application Support/renv/cache"
DOCKER_LOKAL_FILES="/Users/virus-on-mac/Reserve/Repos/hrm_graz"
```

```bash
docker run --rm \
    -e "PASSWORD=graz" \
    -v "${RENV_PATHS_CACHE_HOST}:/home/rstudio/.local/share/renv/cache" \
    -v "${DOCKER_LOKAL_FILES}:/home/rstudio/lokal" \
    -p 8787:8787 \
    melt_graz
```

## MIT Licence 
Copyright (c) 2020 Hannes Oberreiter