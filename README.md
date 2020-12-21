# openshift-webproxy

Simple webproxy that redirects to a bunch of sites maintained in `sites.txt`

## Deployment

```bash
oc new-project webproxy
oc new-app --allow-missing-images -f template.yml -n webproxy
```

## Redeployment

```bash
oc delete sa webproxy -n ng-webproxy ;and oc delete all -n ng-webproxy -l app=webproxy
oc new-app --allow-missing-images -f template.yml -n ng-webproxy
```
