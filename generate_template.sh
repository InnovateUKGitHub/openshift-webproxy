#!/bin/bash

SNIPDIR=openshift_template_snippets
OUTFILE=template.yml

indent() {
  local indentSize=2
  local indent=1
  if [ -n "$1" ]; then indent=$1; fi
  pr -to $(($indent * $indentSize))
}

# Top of file
cp ${SNIPDIR}/00_params.yml ${OUTFILE}
echo >>${OUTFILE}
cat ${SNIPDIR}/01_template-header.yml >>${OUTFILE}

# The easy snippets
for s in {02..07}; do
  cat ${SNIPDIR}/${s}_*.yml | indent 1 >>${OUTFILE}
  [[ ${s} -lt 07 ]] && echo >>${OUTFILE}
done

# Add configmap-sites
SITES=$(cat sites.txt | indent 4)
echo -e "${SITES}" >>${OUTFILE}
echo >>${OUTFILE}

# Add routes
ROUTE_TEMPLATE=$(cat ${SNIPDIR}/08_route-template.yml)
ROUTES=""
while read -r d url; do
  ROUTE="${ROUTE_TEMPLATE//\{\{ DOMAIN \}\}/$d}\n\n"
  ROUTES+=$(echo "${ROUTE}" | indent 1)
done <sites.txt
echo -en "${ROUTES}" >>${OUTFILE}
