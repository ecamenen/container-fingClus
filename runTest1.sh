#!/bin/bash
#
#Script used to perform unitary tests on fingerprint clustering tool
#
#Author: E. CAMENEN
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

#Settings files
FILE_ERR="false"
OUTFILES=( 'average_silhouette.pdf' 'silhouette.pdf' 'pca.pdf' 'heatmap.pdf' 'summary.tsv' 'clusters.tsv')
OUTFILES2=( 'removed.tsv' 'shepard_graph.pdf' 'fusion_levels.pdf' 'dendrogram.pdf' 'within_k.tsv' 'log_w_diff.pdf' 'gap_statistics.pdf' 'elbow.pdf')

#Initialization
declare -x INFILE FUNC OPAR
declare -i PARAMETER NBFAIL=0 NBTEST=0 EXIT
declare -a TESTS
echo '' > resultRuns.log

setUp(){
    INFILE="matrix.txt"
    EXIT=0
    FUNC=${FUNCNAME[1]}
    TESTS=()
    printf "\n- ${FUNC}: "
}

tearDown(){
    rm -r temp/
    mkdir temp/
    for i in `seq 0 $((${#OUTFILES2[@]} -1))`; do
        [ -f ${OUTFILES2[i]} ] && rm ${OUTFILES2[i]}
    done

}

########### ERRORS CATCH ###########

testError(){
    local BOOLEAN_ERR="false"
    local MSG=""

    [ $1 -ne ${EXIT} ] && {
        MSG=${MSG}"Program exited with bad error code: $1.\n"
        BOOLEAN_ERR="true"
    }


     [ ${EXIT} -eq 0 ] && {

        for i in ${OUTFILES[@]}; do
	    	testFileExist ${i}
	    done

	    [ ${FILE_ERR} == "true" ] && {
           MSG=${MSG}"not created.\n"
           BOOLEAN_ERR="true"
        }
     }

    tearDown

    [ ${BOOLEAN_ERR} == "true" ] && {
	    echo $MSG
	    ERRORS=${ERRORS}"\n***************\n##Test \"${TESTS[$2]}\" in $FUNC: \n$MSG"
	    return 1
    }
    return 0
}


testFileExist(){

   [ ! -f "temp/"$1 ]  && {
        MSG=${MSG}"$1 "
        FILE_ERR="true"
    }
}

printError(){
    testError $@
    if [ $? -ne 0 ]; then
        echo -n "E"
        let NBFAIL+=1
    else echo -n "."
    fi
}

########### RUN PROCESS ###########

run(){
	printf "\n\n$NBTEST. ${TESTS[$PARAMETER]}\n" >> resultRuns.log 2>&1
    let NBTEST+=1
    let PARAMETER+=1
    Rscript  fingerprint_clustering.R -i ${INFILE} ${O_PAR} $@ >> resultRuns.log 2>&1
}

getElapsedTime(){
    local END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    local ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:0:2}h ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
}

setOutputPar(){
    OPAR=""
    for i in `seq 0 $((${#OUTFILES[@]} -1))`; do
        let j=${i}+1
        O_PAR=${O_PAR}"--output"${j}" temp/"${OUTFILES[i]}" "
    done
}

########### TESTS ###########

test(){
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        run "-i data/$INFILE ${TESTS[i]}"
        local ACTUAL_EXIT=$?
        printError ${ACTUAL_EXIT} ${i}
    done
}

testsDefault(){
    setUp
    #TESTS=('')
    TESTS=('' '-q' '-v' '-a')
    test
}

testsSep(){
    setUp
    TESTS=( '-s 1')
    test
}

badTestsSep(){
    setUp
    EXIT=1
    TESTS=( '-s 2')
    test
}

testsAlgo(){
    setUp
    for i in `seq 1 9`; do
        TESTS[i]='-t '${i}
    done
    test
}

badTestsAlgo(){
    setUp
    EXIT=1
    TESTS=( '-t 0' '-t 10' )
    test
}

testsDist(){
    setUp
    for i in `seq 1 6`; do
        TESTS[i]='-d '${i}
    done
    test
}

badTestsDist(){
    setUp
    EXIT=1
    TESTS=( '-d 0' '-d 7' )
    test
}

testsAxis(){
    setUp
    for i in `seq 2 4`; do
        TESTS[i-2]='-N '${i}
    done
    test
}

badTestsAxis(){
    setUp
    EXIT=1
    TESTS=( '-N 0' '-N 1' '-N 5' )
    test
}

testsMaxCl(){
    setUp
    for i in `seq 3 4`; do
        TESTS[i-3]='-m '${i}
    done
    test
}

badTestsMaxCl(){
    setUp
    EXIT=1
    TESTS=( '-m 0' '-m 1' '-m 2' '-m 200' )
    test
}

testsNbCl(){
    setUp
    for i in `seq 2 3`; do
        TESTS[i-2]='-n '${i}
    done
    test
}

badTestsNbCl(){
    setUp
    EXIT=1
    TESTS=( '-n 0' '-n 1' '-n 200' )
    test
}

########### MAIN ###########

START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
#printf "Tests in progress, could take an hour...\n"
#[ -d bad ] && rm -rf bad/
mkdir temp/
setOutputPar

testsDefault
testsSep
badTestsSep
testsAlgo
badTestsAlgo
testsDist
badTestsDist
testsAxis
badTestsAxis
testsMaxCl
badTestsMaxCl
testsNbCl
badTestsNbCl

rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime ${START_TIME}
[[ -z ${ERRORS} ]] || exit 1
exit 0