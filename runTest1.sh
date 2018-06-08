#!/bin/bash
#
#Script used to perform unitary tests on pathway enrichment tool
#
#Author: E. CAMENEN
#
#Copyright: PhenoMeNal/INRA Toulouse 2018

#Settings files
OUTFILES=( 'heatmap.pdf' 'optimum_silhouette.pdf' 'silhouette.pdf' 'pca.pdf' 'summary.tsv' 'cluster.tsv' )

#Initialization
declare -x INFILE FUNC
declare -i PARAMETER NBFAIL=0 NBTEST=0
declare -a TESTS
echo '' > resultRuns.log

setUp(){
    INFILE="matrix.txt"
    FUNC=${FUNCNAME[1]}
    TESTS=()
    printf "\n- ${FUNC}: "
}

tearDown(){
    rm -r temp/
    mkdir temp/
    [ -f removed.tsv ] && rm removed.tsv
}

########### ERRORS CATCH ###########

testError(){
    local BOOLEAN_ERR="false"
    local MSG=""

    [ $1 -ne 0 ] && {
        MSG=${MSG}"Program exited with bad error code: $1.\n"
        BOOLEAN_ERR="true"
    }

    [ $1 -eq 0 ] && {
        for i in ${OUTFILES[@]}; do
		testFileExist ${i}
	done
        MSG=${MSG}"not created.\n"
        BOOLEAN_ERR="true"
    }

    tearDown

    [ ${BOOLEAN_ERR} == "true" ] && {
	    #echo $MSG
	    ERRORS=${ERRORS}"\n***************\n##Test \"${TESTS[$2]}\" in $FUNC: \n$MSG"
	    return 1
    }
    return 0
}


testFileExist(){
    [ ! -f $1 ] && MSG=${MSG}"$1 "
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
    #java -jar pathwayEnrichment.jar -gal $@
    let NBTEST+=1
    let PARAMETER+=1
    Rscript  fingerprint_clustering.R -o2 ${OUTFILE1} -o3 ${OUTFILE2} $@ >> resultRuns.log 2>&1
}

getElapsedTime(){
    local END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    local ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:0:2}h ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
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

    TESTS=('')

    test
}


########### MAIN ###########

START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
#printf "Tests in progress, could take an hour...\n"
#[ -d bad ] && rm -rf bad/
mkdir temp/

testsDefault

rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime ${START_TIME}
[[ -z ${ERRORS} ]] || exit 1
exit 0