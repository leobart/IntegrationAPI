# Lightning demo Application (Integration API)

## Setup:

##### 1) Login to Dev Hub org and make it default (-d key):

```sh
sfdx force:auth:web:login -d -a devHub
```

##### 2) Create Scratch org and make it default (-s key):

```sh
sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a integrationAPI
```

##### 3) Push project to Scratch org:

```sh
sfdx force:source:push
```

##### 4) Open Scratch org in browser:

```sh
sfdx force:org:open
```