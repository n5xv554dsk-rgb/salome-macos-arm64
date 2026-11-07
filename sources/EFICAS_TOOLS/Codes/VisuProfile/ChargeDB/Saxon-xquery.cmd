saxonb-xquery  -q:getlabels.xq  -s:$1 | sed -n 's/(\(.*\))/\1/pg' | sed 's/@,@ /@,@/g' | sed 's/\(.*\)@,@$/\1/'
