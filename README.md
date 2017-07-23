# RO Funtimes

This is a super silly demo of deploying an app to AWS with one line.

The app is a reeealy basic REST api for reading and writing keys in a
redis database.

## Usage

### Prereqs

1. Installer Docker
1. Create an SSH key in your AWS account named `rodemo`
1. Snag your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for some `AWS_REGION` and
    ```bash
    $ export AWS_ACCESS_KEY_ID=myid AWS_SECRET_ACCESS_KEY=myaccesskey AWS_REGION=someregion
    ```

### Make it!

```bash
$ docker run --rm -it \
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION \
    -v ${PWD}/output/:/output \
    coreypobrien/ro-fun create
```

### Use it!

```bash
$ curl your.ip.from.above/newkey -d 'asdfasdf
'
Roger Roger
$ curl your.ip.from.above/newkey
asdfasdf
$ curl your.ip.from.above
newkey
```

### Clean it!

```bash
$ docker run --rm -it \
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION \
    -v ${PWD}/output/:/output \
    coreypobrien/ro-fun destroy
```

## Notes and caveats and other things

Did I mention is mostly for fun? It really is an anti-pattern in at least a few major ways.

* The app should be its own image instead of being built on the host
* The deployment should use ASGs
* docker-compose is a pretty crappy way to deploy a Docker app
* The Terraform plan has no variables to change even basic things like names of resources
* Terraform is using local state instead of S3 or some other remote state storage
