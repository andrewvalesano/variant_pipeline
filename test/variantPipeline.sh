#!/bin/bash

EXPECTED_ARGS=4
if [ $# -ne $EXPECTED_ARGS ]; then
    echo "Usage: `basename $0` {input_dir} {output_dir} {reference}"
    echo "Example `basename $0` /projectA/input_fastq projectA /bowtie2/pWH2000 control"
    echo "  input_dir should be absolute path to dir containing fastq pairs (left and right)"
    exit 1
fi

INPUT_DIR=`readlink -f $1`
OUTPUT_DIR=`readlink -f $2`
REF=`readlink -f $3`
CONTROL=$4
TEST_DIR=`dirname $0`
BIN_DIR=`readlink -f $TEST_DIR../bin/` 
SCRIPT_DIR=`readlink -f $BIN_DIR/../scripts/`
LIB_DIR=`readlink -f $BIN_DIR/../lib`
BPIPE_COMMAND=$LIB_DIR/bpipe-0.9.8.2/bin/bpipe

echo "Processing fastqs from [$INPUT_DIR]."
echo "Results will be saved to [$OUTPUT_DIR]."
echo " Using [$REF] for a reference."
echo "Using [$TEST_DIR] for a TEST directory."

mkdir -p $OUTPUT_DIR || exit 1
cd $OUTPUT_DIR
cp -a $SCRIPT_DIR/variantPipeline.bpipe* . 


# add variables to config reference to config file

sed -i '7iREFERENCE="'$REF'"' variantPipeline.bpipe.config
sed -i '8iREFERENCE.FA="'$REF'.fa"' variantPipeline.bpipe.config
sed -i '9iSCRIPTS="'$SCRIPT_DIR'"' variantPipeline.bpipe.config
sed -i '10iLIBRARY_LOCATION="'$LIB_DIR'"' variantPipeline.bpipe.config
sed -i '11iCONTROL="'$CONTROL'"' variantPipeline.bpipe.config


#throttled to 8 processors to be a good neighbor.
#note that running unthrottled can result in errors when bpipe overallocates threads/memory
time $BPIPE_COMMAND test  -n 8  variantPipeline.bpipe $INPUT_DIR/*.fastq

