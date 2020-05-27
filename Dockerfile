FROM rocker/tidyverse:4.0.0

LABEL maintainer= 'hoberreiter@gmail.com'

COPY git_config.sh /etc/cont-init.d/gitconfig
COPY . /home/rstudio/project
RUN chown -R rstudio /home/rstudio/project

ENV RENV_VERSION 0.10.0
RUN Rscript -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN Rscript -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# rgl package, used in qpcR package
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	libglu1-mesa-dev

# httpuv https://github.com/rstudio/shiny/issues/2073
RUN apt-get -y --no-install-recommends install \
	gfortran libreadline6-dev libx11-dev libxt-dev libcairo2-dev libbz2-dev liblzma-dev libcurl4-openssl-dev cmake

RUN mkdir /home/rstudio/.local
RUN mkdir /home/rstudio/.local/share
RUN mkdir /home/rstudio/.local/share/renv
RUN mkdir /home/rstudio/.local/share/renv/binary

# TODO dont chmod a+rwx? Cannot install binaries and project wihout it (env::init())
RUN chmod a+rwx /home/rstudio/.local
RUN chown -R rstudio /home/rstudio/.local
