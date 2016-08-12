#!/bin/bash
#SBATCH --time=24:00:00

#export DO_PYPYLOG="jit-summary"
#~/.local/bin/rebench -N -d -v rebench_0.6.conf CrossBenchmarks

# Checkout the lastest pycket and pypy
cd pycket
git pull
make setup
PYCKET_HASH=$(git rev-parse HEAD)
PYPY_HASH=$(cd pypy; hg id)

echo "Pycket: ${PYCKET_HASH}"
echo "PyPy: ${PYPY_HASH}"

make translate-jit
cd ..

rm output/CrossBenchmarks.tsv
# Run the benchmarks
~/.local/bin/rebench -N -d -v rebench_0.6.conf CrossBenchmarks

FILENAME="${PYCKET_HASH}_${PYPY_HASH}.tsv"
OUTFILE="pycket-profiles/${FILENAME}"
mv output/CrossBenchmarks.tsv $OUTFILE

cd pycket-profiles
git add $FILENAME
git commit -am "adding profile: ${FILENAME}"
git pull
git push

