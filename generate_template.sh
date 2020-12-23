#!/bin/bash

SNIPDIR=openshift_template_snippets
OUTFILE=template.yml
INT=00
ENV=${ENV:-dev}
DEPLOY_ENV=${DEPLOY_ENV:-org-env-0}

indent() {
  local indentSize=2
  local indent=1
  if [ -n "$1" ]; then indent=$1; fi
  pr -to $(($indent * $indentSize))
}

zeropad() {
  INT=$(printf "%02d" "$1")
}

if [ "${ENV}" == 'prod' ]; then
  INDENTED_TLS_KEY=$(pass show /CI/${DEPLOY_ENV}/webproxy/star_innovateuk_org.key | indent 2)
  INDENTED_TLS_CRT=$(pass show /CI/${DEPLOY_ENV}/webproxy/star_innovateuk_org.crt | indent 2)
  INDENTED_TLS_CA=$(pass show /CI/${DEPLOY_ENV}/webproxy/DigiCertCA.crt | indent 2)
fi

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
if [ -n "${WEBHOOK_SECRET_b64}" ]; then
  SITES=$(cat ${SNIPDIR}/15_secret-webhook.yml | indent 1)
  echo -e "${SITES}" >>${OUTFILE}
  echo >>${OUTFILE}
fi

# Add routes
ROUTE_TEMPLATE=$(cat ${SNIPDIR}/20_route-template.yml)
ROUTES=""
while read -r d url; do
  ROUTE="${ROUTE_TEMPLATE//\{\{ DOMAIN \}\}/$d}\n"
  if [ ${ENV} == 'prod' ]; then
    TLS="  key: |-\n"
    TLS+="${INDENTED_TLS_KEY}"
    TLS+="\n  certificate: |-\n"
    TLS+="${INDENTED_TLS_CRT}"
    TLS+="\n  caCertificate: |-\n"
    TLS+="${INDENTED_TLS_CA}\n\n"
    ROUTE+="$(echo -en "${TLS}" | indent 2)"
  fi
  ROUTES+="$(echo -e "${ROUTE}" | indent 1)\n"
done <sites.txt
echo -en "${ROUTES}" >>${OUTFILE}
