FROM rocker/tidyverse:4.0.0

COPY git_config.sh /etc/cont-init.d/gitconfig
COPY . /home/rstudio/project
RUN chown -R rstudio /home/rstudio/project

ENV RENV_VERSION 0.10.0
RUN Rscript -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN Rscript -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# we need flu for rgl package, used in qpcR package
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	libglu1-mesa-dev

#WORKDIR /project
#COPY renv.lock renv.lock

#ENV RENV_PATHS_CACHE ~/renv/cache
#RUN R -e 'renv::consent(provided = TRUE)'

# we don't want to create full docker image, see run in readme.md
#RUN R -e 'renv::restore()'
