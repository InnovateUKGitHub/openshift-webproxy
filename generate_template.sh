#!/bin/bash

SNIPDIR=openshift_template_snippets
OUTFILE=template.yml
INT=00

indent() {
  local indentSize=2
  local indent=1
  if [ -n "$1" ]; then indent=$1; fi
  pr -to $(($indent * $indentSize))
}

zeropad() {
  INT=$(printf "%02d" "$1")
}

# Top of file
cp ${SNIPDIR}/00_params.yml ${OUTFILE}
echo >>${OUTFILE}
cat ${SNIPDIR}/01_template-header.yml >>${OUTFILE}

# The easy snippets
for s in {2..8}; do
  zeropad "${s}" # 'returns' $INT
  cat ${SNIPDIR}/${INT}_*.yml | indent 1 >>${OUTFILE}
  [[ "${s}" -lt 8 ]] && echo >>${OUTFILE}
done

# Add configmap-sites
SITES=$(cat sites.txt | indent 4)
echo -e "${SITES}" >>${OUTFILE}
echo >>${OUTFILE}

# Add webhook secret, if set
# WEBHOOK_SECRET_b64=$(echo ${WEBHOOK_SECRET} | base64)
if [ -n "${WEBHOOK_SECRET_b64}" ]; then
  SITES=$(cat ${SNIPDIR}/15_secret-webhook.yml | indent 1)
  echo -e "${SITES}" >>${OUTFILE}
  echo >>${OUTFILE}
fi

# Add routes
ROUTE_TEMPLATE=$(cat ${SNIPDIR}/20_route-template.yml)
ROUTES=""
while read -r d url; do
  ROUTE="${ROUTE_TEMPLATE//\{\{ DOMAIN \}\}/$d}\n\n"
  ROUTES+=$(echo "${ROUTE}" | indent 1)
done <sites.txt
echo -en "${ROUTES}" >>${OUTFILE}
