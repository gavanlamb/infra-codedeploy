# CodeDeploy shared resources

## Azure DevOps
### Templates
#### Variables


#### Deploy
Trigger a CodeDeploy deployment.

This template will:
1. Push AppSpec file
2. Deploy
3. Stop deploy if the run is cancelled or has failed and the deployment has begun

The [deploy](./pipelines/templates/deploy.yml) template is a [step](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#step-reuse) template meaning it needs to be nested under a `steps:` block.

##### Parameters
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

##### Example
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
                - template: ./pipelines/templates/deploy.yml@templates
                  parameters:
                    serviceName: time-api
```


#### 


#### 