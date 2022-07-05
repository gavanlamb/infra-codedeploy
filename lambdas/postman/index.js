'use strict';

const newman = require('newman');
const aws = require('aws-sdk');
const fs = require("fs");
const fsPromises = require("fs").promises;

const getConfiguration = async (
    deploymentId) => {
    const codeDeploy = aws.CodeDeploy();
    const params = {
        deploymentId: deploymentId
    };

    const response = await codeDeploy.getDeployment(params).promise();
    const bucket = response.deploymentInfo.s3location.bucket;
    const key = response.deploymentInfo.s3location.key;

    const pathSegments = key.split('/');
    pathSegments.pop();
    pathSegments.pop();
    pathSegments.push('postman');
    const testsBasePath = pathSegments.join('/');
    return {
        bucket: bucket,
        key: key,
        collectionFileKey: `${testsBasePath}/tests/tests.postman_collection.json`,
        environmentFileKey: `${testsBasePath}/tests/environment.postman_collection.json`,
        resultsFileKey: `${testsBasePath}/results/results.xml`,
        resultsFileLocalPath: '/tmp/results.xml'
    }
};

const downloadFile = async (
    bucket,
    path,
    filename) => {
    const s3 = new aws.S3();
    const object = await s3.getObject(
        {
            Bucket: bucket,
            Key: `${path}/${filename}`
        }).promise();
    const filePath = `/tmp/${filename}`
    await fsPromises.writeFile(filePath, object.Body);
    return filePath;
};

const notifyCodeDeploy = (
    deploymentId,
    lifecycleEventHookExecutionId,
    status,
    resolve,
    reject) => {
    const params = {
        deploymentId: deploymentId,
        lifecycleEventHookExecutionId: lifecycleEventHookExecutionId,
        status: status
    };

    const codeDeploy = new aws.CodeDeploy({apiVersion: '2014-10-06'});
    codeDeploy.putLifecycleEventHookExecutionStatus(
        params,
        (codeDeployError, codeDeployData) => {
            if (codeDeployError) {
                console.error(codeDeployError);
                if(reject){
                    reject("Failed to place lifecycle event");
                }
            } else {
                console.log(codeDeployData);
                if(resolve){
                    resolve(null, 'Successfully placed lifecycle event');
                }
            }
        });
}

exports.handler = async (event) => {
    const configuration = await getConfiguration();
    const collectionFilePath = await downloadFile(configuration.collectionFileKey);
    const environmentFilePath = await downloadFile(configuration.environmentFileKey);

    await new Promise(resolve => setTimeout(resolve, 10000));

    return new Promise(
        function(resolve, reject) {
            newman.run(
                {
                    collection: collectionFilePath,
                    environment: environmentFilePath,
                    delayRequest: 9000,
                    reporters: 'junitfull',
                    reporter: {
                        junitfull: {
                            export: configuration.resultsFileLocalPath,
                        },
                    },
                },
                (newmanError, newmanData) => {
                    if (configuration.bucket) {
                        const s3 = new aws.S3();
                        const testResultsData = fs.readFileSync(configuration.resultsFileLocalPath, 'utf8');
                        s3.upload(
                            {
                                ContentType: "application/xml",
                                Bucket: configuration.bucket,
                                Body: testResultsData,
                                Key: configuration.resultsFileKey
                            },
                            function (s3Error, s3Data) {
                                console.log(JSON.stringify(s3Error ? s3Error : s3Data));
                                console.log(newmanError);
                                console.log(newmanData);
                                console.log(newmanData?.run?.failures);
                                notifyCodeDeploy(
                                    event.DeploymentId,
                                    event.LifecycleEventHookExecutionId,
                                    newmanError || newmanData?.run?.failures.length > 0 ? 'Failed' : 'Succeeded',
                                    resolve,
                                    reject);
                            }
                        );
                    }
                }
            );
        }
    );
}
