# openshift-webproxy

Simple webproxy that redirects to a bunch of sites maintained in `sites.txt`

## OpenShift project creation

Create a project/namespace to hold the gubbins.  Use a node selector of 'dev' or 'prod' to allocate to specific node types (defaults to 'dev').

```bash
oc adm new-project my-webproxy --node-selector='purpose=dev'
oc project my-webproxy
```

## Deployment

```bash
make deploy
```

Optionally, you can create a webhook for GitHub by setting and passing in a webhook secret.  Also pass in ENV as 'dev' or 'prod' (defaults to 'dev').  In 'prod' real certs are pulled from 'pass', whilst 'dev' uses the openshift default router certs:

```bash
make deploy WEBHOOK_SECRET=mysecret ENV=dev
```

## Redeployment

```bash
make redeploy ENV=dev
```

Optionally, you can create a webhook for GitHub by setting and passing in a webhook secret:

```bash
make redeploy WEBHOOK_SECRET=mysecret ENV=dev
```

## Undeployment

```bash
make undeploy
```

## Remove openshift project

```bash
oc project delete my-webproxy
```
