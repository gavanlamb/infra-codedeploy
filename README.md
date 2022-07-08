# CodeDeploy shared resources

## Azure DevOps
### Templates
#### Deploy
Trigger a CodeDeploy deployment.

This template will:
1. Push AppSpec file
2. Deploy
3. Stop deploy if the run is cancelled or has failed and the deployment has begun

The [deploy](./pipelines/templates/deploy.yml) template is a [step](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#step-reuse) template meaning it needs to be nested under a `steps:` block.

This template does require AWS credentials to be set up, which can be achieved using the [configure](#configure) template.

###### Parameters
| Name             | Description                                  | Type   | Default                 |
|:-----------------|:---------------------------------------------|:-------|:------------------------|
| applicationName  | Name of the codedeploy application           | string |                         |
| buildNumber      | Build number                                 | string |                         |
| codeDeployBucket | Name of codedeploy bucket                    | string |                         |
| environment      | Environment name                             | string |                         |
| serviceName      | Name of service                              | string |                         |
| workingDirectory | Directory where the app spec file is located | string | `$(Pipeline.Workspace)` |

###### Example
```yaml
steps:
  - template: ./pipelines/templates/deploy.yml@templates
    parameters:
      applicationName: time-production
      buildNumber: $(Build.BuildNumber)
      codeDeployBucket: codedeploy
      environment: production
      serviceName: time
      workingDirectory: $(Pipeline.Workspace)
```


#### 


#### 