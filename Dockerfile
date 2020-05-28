FROM rocker/tidyverse:3.6.3

LABEL maintainer="hoberreiter@gmail.com"

COPY git_config.sh /etc/cont-init.d/gitconfig
COPY . /home/rstudio/project
RUN chown -R rstudio /home/rstudio/project
ENV DISABLE_AUTH=true

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	libftgl2 \ 
	libcgal-dev \
	libx11-dev \
	libfreetype6-dev \
	libglu1-mesa-dev \
	r-cran-httpuv

RUN install2.r boot vegan qpcR

### Old code, not using ENV for this project

# rgl package, used in qpcR package


# httpuv https://github.com/rstudio/shiny/issues/2073
#RUN apt-get -y --no-install-recommends install \
#	gfortran libxt-dev libcairo2-dev libbz2-dev liblzma-dev libcurl4-openssl-dev cmake


#ENV RENV_VERSION 0.10.0
#RUN Rscript -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
#RUN Rscript -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"


# RUN mkdir -p /home/rstudio/.local/share/renv/binary

# # TODO dont chmod a+rwx? Cannot install binaries and project wihout it (env::init())
# RUN chmod a+rwx /home/rstudio/.local \
#      && chown -R rstudio /home/rstudio/.local

