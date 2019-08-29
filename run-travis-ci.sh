#!/bin/sh

# Author: Andreas Röhler <andreas.roehler@easy-emacs.de>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# Commentary:

# Code:

PDIR=$PWD
echo "\$PWD: $PWD"

TESTDIR=$PDIR/test
export TESTDIR

TTS=$PDIR/text2speech.el

echo "\$TTS: $TTS"

TEST1=$TESTDIR/text2speech-tests.el

if [ -s emacs27 ]; then
    EMACS=emacs27
else
    EMACS=emacs
fi

echo "\$EMACS: $EMACS"

hier() {
    date; time -p $EMACS -Q --batch \
--eval "(message (emacs-version))" \
--eval "(setq py-switch-p nil)" \
--eval "(add-to-list 'load-path \"$PDIR/\")" \
--eval "(add-to-list 'load-path \"$TESTDIR/\")" \
-load $TTS \
-l $TEST1 \
-f ert-run-tests-batch-and-exit
}

entfernt() {
$EMACS -Q --batch \
--eval "(message (emacs-version))" \
--eval "(setq py-switch-p nil)" \
--eval "(add-to-list 'load-path \"$PDIR/\")" \
--eval "(add-to-list 'load-path \"$TESTDIR/\")" \
-load $TTS \
-l $TEST1 \

-f ert-run-tests-batch-and-exit
}

if [ $WERKSTATT -eq 0 ]; then
    echo "Lade testumgebung \"HIER1\"";
    hier

else
    echo "Lade testumgebung \"ENTFERNT\""
    entfernt
fi

# -l $TEST1 \
# -l $TEST2 \
# -l $TEST4 \
# -l $TEST5 \
# -l $TEST6 \
# -l $TEST7 \
# -l $TEST8 \
# -l $TEST11 \
# -l $TEST12 \
# -l $TEST13 \
# -l $TEST14 \
# -l $TEST15 \
# -l $TEST16 \
