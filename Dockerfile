#Dockerfile for clustering tool
#
#Author: E. Camenen
#
###############################################################################
 # Copyright INRA
 #
 #  Contact: ludovic.cottret@toulouse.inra.fr
 #
 #
 # This software is governed by the CeCILL license under French law and
 # abiding by the rules of distribution of free software.  You can  use,
 # modify and/ or redistribute the software under the terms of the CeCILL
 # license as circulated by CEA, CNRS and INRIA at the following URL
 # "http://www.cecill.info".
 #
 # As a counterpart to the access to the source code and  rights to copy,
 # modify and redistribute granted by the license, users are provided only
 # with a limited warranty  and the software's author,  the holder of the
 # economic rights,  and the successive licensors  have only  limited
 # liability.
 #  In this respect, the user's attention is drawn to the risks associated
 # with loading,  using,  modifying and/or developing or reproducing the
 # software by the user in light of its specific status of free software,
 # that may mean  that it is complicated to manipulate,  and  that  also
 # therefore means  that it is reserved for developers  and  experienced
 # professionals having in-depth computer knowledge. Users are therefore
 # encouraged to load and test the software's suitability as regards their
 # requirements in conditions enabling the security of their systems and/or
 # data to be ensured and,  more generally, to use and operate it in the
 # same conditions as regards security.
 #  The fact that you are presently reading this means that you have had
 # knowledge of the CeCILL license and that you accept its terms.
###############################################################################

FROM ubuntu:16.04

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

ENV TAG_NUMBER 3.3
ENV SOFT_NAME fingerprint_clustering

LABEL Description="Performs unsupervised clustering and automatically determine the best number of cluster"
LABEL software.version=3.3
LABEL version=1.4
LABEL software="FingerprintClustering"
LABEL website="metexplore.toulouse.inra.fr"
LABEL tags="Metabolomics"

RUN apt-get update && apt-get install -y --no-install-recommends git && apt-get install -y r-base && \
	git clone --depth 1 --single-branch --branch $TAG_NUMBER http://github.com/MetExplore/phnmnl-FingerprintClustering.git $SOFT_NAME && \
	cd $SOFT_NAME && \
	git checkout $TAG_NUMBER && \
	cp -r data/ $SOFT_NAME.R / && \
	apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	cd / && rm -rf $SOFT_NAME

ADD runTest1.sh /usr/local/bin/runTest1.sh
RUN chmod +x /usr/local/bin/runTest1.sh

ENTRYPOINT ["Rscript", "fingerprint_clustering.R"]