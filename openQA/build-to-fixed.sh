SCENARIO=${4:-"*"}
TAG=${3:-"GM"}
ARCH=${5:-"*"}
SEARCH_STRING="'*$1-$ARCH-$2*-$SCENARIO@*'"
COPY_ACTION=${6:-"-exec cp \{\} fixed/ \;"}
DELETE_ACTION_COMMAND="-exec rename -v '$2' $TAG {} \; "
DELETE_ACTION=${7:-$DELETE_ACTION_COMMAND}
echo find . -maxdepth 1 -name ${SEARCH_STRING} $COPY_ACTION 
echo find fixed -name ${SEARCH_STRING} $DELETE_ACTION 
