# CodeDeploy shared resources

## Azure DevOps
### Templates
#### Variables

#### Tasks
##### Deploy
Deploy the specified asset. This template orchestrates `Create Deployment`, `Publish Postman Results`, `Publish Postman Tests`.

###### Parameters
| Name                   | Description                                                                                                                   | Type   | Default                     | Default value found in                                                    |
|:-----------------------|:------------------------------------------------------------------------------------------------------------------------------|:-------|:----------------------------|---------------------------------------------------------------------------|
| awsAccessKeyId         | AWS access key id                                                                                                             | string | `$(AWS_ACCESS_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsSecretKeyId         | AWS secret key id                                                                                                             | string | `$(AWS_SECRET_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsDefaultRegion       | AWS default region                                                                                                            | string | `$(AWS_DEFAULT_REGION)`     | Variable group named `{{environment}}.{{AWS region}}`                     |
| buildNumber            | Build number                                                                                                                  | string | `$(Build.BuildNumber)`      |                                                                           |
| codeDeployBucket       | Name of codedeploy bucket                                                                                                     | string | `$(CODEDEPLOY_BUCKET_NAME)` | Variable template in this repository `{{environment}}.{{AWS region}}.yml` |
| postmanEnvironmentFile | Postman environment file to upload                                                                                            | string | ''                          |                                                                           |
| environment            | Environment name                                                                                                              | string | `$(ENVIRONMENT)`            | Variable group named `{{environment}}.{{AWS region}}`                     |
| serviceName            | Name of service                                                                                                               | string |                             |                                                                           |
| postmanTestFile        | Postman test file to upload. If not specified the `Publish Postman Results` and `Publish Postman Tests` tasks will not be run | string | ''                          |                                                                           |
| workingDirectory       | Directory where the app spec file is located                                                                                  | string | `$(Pipeline.Workspace)`     |


###### Example
```yaml
resources:
  repositories:
    - repository: codedeploy-templates
      type: github
      name: expensely/codedeploy
      endpoint: expensely
      
stages:
  - stage: production
    displayName: Production
    jobs:
      - deployment: deploy
        displayName: Deploy
        dependsOn: approve
        environment: Production
        variables:
          - group: production.ap-southeast-2
          - template: pipelines/variables/production.ap-southeast-2.yml@codedeploy-templates
        strategy:
          runOnce:
            deploy:
              steps:
                - download: none
                ...
                - template: ./pipelines/templates/deployt.yml@codedeploy-templates
                  parameters:
                    postmanEnvironmentFile: tests/Time.ApiTests/collections/time.postman_collection.json
                    serviceName: time-api
                    postmanTestFile: tests/Time.ApiTests/collections/preview.postman_collection.json
                ...
```

##### Create Deployment
Trigger a CodeDeploy deployment.

This template will:
1. Push AppSpec file
2. Deploy
3. Stop deploy if the run is cancelled or has failed and the deployment has begun

The [create-deployment](./pipelines/templates/create-deployment.yml) template is a [step](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#step-reuse) template meaning it needs to be nested under a `steps:` block.

###### Parameters
| Name             | Description                                  | Type   | Default                     | Default value found in                                                    |
|:-----------------|:---------------------------------------------|:-------|:----------------------------|---------------------------------------------------------------------------|
| awsAccessKeyId   | AWS access key id                            | string | `$(AWS_ACCESS_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsSecretKeyId   | AWS secret key id                            | string | `$(AWS_SECRET_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsDefaultRegion | AWS default region                           | string | `$(AWS_DEFAULT_REGION)`     | Variable group named `{{environment}}.{{AWS region}}`                     |
| buildNumber      | Build number                                 | string | `$(Build.BuildNumber)`      |                                                                           |
| codeDeployBucket | Name of codedeploy bucket                    | string | `$(CODEDEPLOY_BUCKET_NAME)` | Variable template in this repository `{{environment}}.{{AWS region}}.yml` |
| environment      | Environment name                             | string | `$(ENVIRONMENT)`            | Variable group named `{{environment}}.{{AWS region}}`                     |
| serviceName      | Name of service                              | string |                             |                                                                           |
| workingDirectory | Directory where the app spec file is located | string | `$(Pipeline.Workspace)`     |                                                                           |

###### Example
```yaml
resources:
  repositories:
    - repository: codedeploy-templates
      type: github
      name: expensely/codedeploy
      endpoint: expensely
      
stages:
  - stage: production
    displayName: Production
    jobs:
      - deployment: deploy
        displayName: Deploy
        dependsOn: approve
        environment: Production
        variables:
          - group: production.ap-southeast-2
          - template: pipelines/variables/production.ap-southeast-2.yml@codedeploy-templates
        strategy:
          runOnce:
            deploy:
              steps:
                - download: none
                ...
                - template: ./pipelines/templates/create-deployment.yml@codedeploy-templates
                  parameters:
                    serviceName: time-api
                ...
```

##### Publish Postman Tests
Publish postman results

This template will:
1. Upload Postman test

The [publish-postman-tests](./pipelines/templates/publish-postman-tests.yml) template is a [step](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#step-reuse) template meaning it needs to be nested under a `steps:` block.

###### Parameters
| Name             | Description                                  | Type   | Default                     | Default value found in                                                    |
|:-----------------|:---------------------------------------------|:-------|:----------------------------|---------------------------------------------------------------------------|
| awsAccessKeyId   | AWS access key id                            | string | `$(AWS_ACCESS_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsSecretKeyId   | AWS secret key id                            | string | `$(AWS_SECRET_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsDefaultRegion | AWS default region                           | string | `$(AWS_DEFAULT_REGION)`     | Variable group named `{{environment}}.{{AWS region}}`                     |
| buildNumber      | Build number                                 | string | `$(Build.BuildNumber)`      |                                                                           |
| codeDeployBucket | Name of codedeploy bucket                    | string | `$(CODEDEPLOY_BUCKET_NAME)` | Variable template in this repository `{{environment}}.{{AWS region}}.yml` |
| environmentFile  | Environment file to upload                   | string |                             |                                                                           |
| environment      | Environment name                             | string | `$(ENVIRONMENT)`            | Variable group named `{{environment}}.{{AWS region}}`                     |
| serviceName      | Name of service                              | string |                             |                                                                           |
| testFile         | Test file to upload                          | string |                             |                                                                           |
| workingDirectory | Directory where the app spec file is located | string | `$(Pipeline.Workspace)`     |                                                                           |

###### Example
```yaml
resources:
  repositories:
    - repository: codedeploy-templates
      type: github
      name: expensely/codedeploy
      endpoint: expensely
      
stages:
  - stage: production
    displayName: Production
    jobs:
      - deployment: deploy
        displayName: Deploy
        dependsOn: approve
        environment: Production
        variables:
          - group: production.ap-southeast-2
          - template: pipelines/variables/production.ap-southeast-2.yml@codedeploy-templates
        strategy:
          runOnce:
            deploy:
              steps:
                - download: none
                ...
                - template: ./pipelines/templates/publish-postman-tests.yml@codedeploy-templates
                  parameters:
                    environmentFile: tests/Time.ApiTests/collections/time.postman_collection.json
                    serviceName: time-api
                    testFile: tests/Time.ApiTests/collections/preview.postman_collection.json
                ...
```

##### Publish Postman Results
Publish postman results

This template will:
1. Download Postman test results file
2. Publish Postman test results file

The [publish-postman-results](./pipelines/templates/publish-postman-results.yml) template is a [step](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#step-reuse) template meaning it needs to be nested under a `steps:` block.

###### Parameters
| Name             | Description                                  | Type   | Default                     | Default value found in                                                    |
|:-----------------|:---------------------------------------------|:-------|:----------------------------|---------------------------------------------------------------------------|
| awsAccessKeyId   | AWS access key id                            | string | `$(AWS_ACCESS_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsSecretKeyId   | AWS secret key id                            | string | `$(AWS_SECRET_KEY_ID)`      | Variable group named `{{environment}}.{{AWS region}}`                     |
| awsDefaultRegion | AWS default region                           | string | `$(AWS_DEFAULT_REGION)`     | Variable group named `{{environment}}.{{AWS region}}`                     |
| buildNumber      | Build number                                 | string | `$(Build.BuildNumber)`      |                                                                           |
| codeDeployBucket | Name of codedeploy bucket                    | string | `$(CODEDEPLOY_BUCKET_NAME)` | Variable template in this repository `{{environment}}.{{AWS region}}.yml` |
| environment      | Environment name                             | string | `$(ENVIRONMENT)`            | Variable group named `{{environment}}.{{AWS region}}`                     |
| serviceName      | Name of service                              | string |                             |                                                                           |
| workingDirectory | Directory where the app spec file is located | string | `$(Pipeline.Workspace)`     |                                                                           |

###### Example
```yaml
resources:
  repositories:
    - repository: codedeploy-templates
      type: github
      name: expensely/codedeploy
      endpoint: expensely
      
stages:
  - stage: production
    displayName: Production
    jobs:
      - deployment: deploy
        displayName: Deploy
        dependsOn: approve
        environment: Production
        variables:
          - group: production.ap-southeast-2
          - template: pipelines/variables/production.ap-southeast-2.yml@codedeploy-templates
        strategy:
          runOnce:
            deploy:
              steps:
                - download: none
                ...
                - template: ./pipelines/templates/publish-postman-results.yml@codedeploy-templates
                  parameters:
                    serviceName: time-api
                ...
```
