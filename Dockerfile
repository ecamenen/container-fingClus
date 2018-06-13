#Dockerfile for pathway enrichment tool
#
#Author: E. Camenen
#
#Copyright: PhenoMeNal/INRA Toulouse 2017

FROM ubuntu:16.04

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

ENV TAG_NUMBER 3.2
ENV SOFT_NAME fingerprint_clustering

LABEL Description="Performs unsupervised clustering and automatically determine the best number of cluster"
LABEL software.version=$TAG_NUMBER
LABEL version="1.1"
LABEL software="FingerprintClustering"
LABEL website="metexplore.toulouse.inra.fr"
LABEL tags="Metabolomics"

RUN apt-get update && apt-get install -y --no-install-recommends git && apt-get install -y r-base && \
	git clone --depth 1 --single-branch --branch $TAG_NUMBER http://github.com/MetExplore/phnmnl-FingerprintClustering.git $SOFT_NAME && \
	cd $SOFT_NAME && \
	git checkout $TAG_NUMBER && \
	cp -r data/ launcher.R $SOFT_NAME.R / && \
	apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	cd / && rm -rf $SOFT_NAME

ADD runTest1.sh /usr/local/bin/runTest1.sh

ENTRYPOINT ["Rscript", "launcher.R"]