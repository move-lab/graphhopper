# Graphhopper

| PROD                                                                                                        |
| ----------------------------------------------------------------------------------------------------------- |
| ![Build Status](https://bamboo.intapps.it/plugins/servlet/wittified/build-status/LAB-LABGRAPHHOPPERSERVICE) |
| ![prod Deployment](https://bamboo.intapps.it/plugins/servlet/wittified/deploy-status/95978062)              |

**Description**: see [README](./GRAPHHOPPER_README.md).

## Usage

### Create/Update S3 Bucket

The S3 bucket is managed via CFN Template in the .aws folder

```bash
aws cloudformation <create|update>-stack \
  --profile movelab \
  --stack-name lab-graphhopper-graphdata-prod \
  --template-body file://./.aws/graphdata.s3.yaml \
  --parameters ParameterKey=ServiceName,ParameterValue=lab-graphhopper-graphdata-prod
```

### Build Image

```shell
docker build . -t docker.intapps.it/graphhopper:$(git rev-parse HEAD)
```

### Start

```shell
docker run -p 8989:8989 docker.intapps.it/graphhopper:$(git rev-parse HEAD)
```

### Merge PBF files via `osmosis`

```bash
osmosis \
  --read-pbf file=hamburg-latest.osm.pbf \
  --read-pbf file=berlin-latest.osm.pbf \
  --merge \
  --write-pbf \
  omitmetadata=true \
  file=b_hh_lndn_merged.pbf
```

### Build + Deploy Graph

#### Start graphhopper, mount volume and pass path to pbf file.

**NOTE**: the `-i` expects the path from within the docker container context

```bash
docker run -p 8999:8989 -v </path/to/pbf/file/>:/data docker.intapps.it/graphhopper:$(git rev-parse HEAD) -i <path/to/pbf/file>.pbf
```

e.g.:

```bash
docker run -p 8999:8989 -v /Users/macuser/Desktop/pbf:/data docker.intapps.it/graphhopper:$(git rev-parse HEAD) -i /data/b_hh_lndn_dnmrk_merged.pbf
```

#### Zip the created pbf file

```bash
tar -zcvf <filename>.gz <path/to/build/graphdata>
```

#### Upload .gz file into the s3 bucket via

```bash
aws s3 cp /path/to/file.name s3://lab-graphhopper-graphdata-prod --profile movelab --region eu-west-1 --recursive
```

**NOTE**: If you want to use the compiled graph files use the following commands:

e.g.

```bash
docker run <...> -pg /data/graphdata/graphdata_b_hh_lndn.osm-gh -dp s3://lab-graphhopper-graphdata-prod/graphdata_b_hh_lndn.gz
```

The script will download the data from `s3://lab-graphhopper-graphdata-prod/graphdata_b_hh_lndn.gz`.
Then `graphdata_b_hh_lndn.gz` will be extracted into a folder called `graphdata_b_hh_lndn.osm-gh` (In this case).

During the startup, graphhopper will look in `/data/graphdata/graphdata_b_hh_lndn.osm-gh/` where the built graph is then located.
