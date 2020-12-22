# openshift-webproxy

Simple webproxy that redirects to a bunch of sites maintained in `sites.txt`

## Deployment

```bash
make deploy
```

Optionally, you can create a webhook for GitHub by setting and passing in a webhook secret:

```bash
make deploy WEBHOOK_SECRET=mysecret
```

## Redeployment

```bash
make redeploy
```

Optionally, you can create a webhook for GitHub by setting and passing in a webhook secret:

```bash
make redeploy WEBHOOK_SECRET=mysecret
```

## Undeployment

```bash
make undeploy
```
