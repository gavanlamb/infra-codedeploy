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
        collectionFileLocalPath: `/tmp/tests.postman_collection.json`,
        environmentFileKey: `${testsBasePath}/tests/environment.postman_environment.json`,
        environmentFileLocalPath: `/tmp/environment.postman_environment.json`,
        resultsFileKey: `${testsBasePath}/results/results.xml`,
        resultsFileLocalPath: '/tmp/results.xml'
    }
};

const downloadFile = async (
    bucket,
    key,
    localPath) => {
    const s3 = new aws.S3();
    const object = await s3.getObject(
        {
            Bucket: bucket,
            Key: key
        }).promise();
    await fsPromises.writeFile(localPath, object.Body);
};

const uploadFile = (
    bucket,
    key,
    localPath) => {
    const s3 = new aws.S3();
    const testResultsData = fs.readFileSync(localPath, 'utf8');
    s3.upload(
        {
            ContentType: "application/xml",
            Bucket: bucket,
            Body: testResultsData,
            Key: key
        },
        function (s3Error, s3Data) {
            console.log(JSON.stringify(s3Error ? s3Error : s3Data));
        }
    );
}

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
    const configuration = await getConfiguration(
        event.DeploymentId);
    await Promise.all([
        downloadFile(
            configuration.bucket,
            configuration.collectionFileKey,
            configuration.collectionFileLocalPath),
        downloadFile(
            configuration.bucket,
            configuration.environmentFileKey,
            configuration.environmentFileLocalPath)
    ]);

    return new Promise(
        function(resolve, reject) {
            newman.run(
                {
                    collection: configuration.collectionFileLocalPath,
                    environment: configuration.environmentFileLocalPath,
                    delayRequest: 500,
                    reporters: 'junitfull',
                    reporter: {
                        junitfull: {
                            export: configuration.resultsFileLocalPath,
                        }
                    }
                },
                (newmanError, newmanData) => {
                    console.log(newmanError);
                    console.log(newmanData);
                    uploadFile(
                        configuration.bucket,
                        configuration.resultsFileKey,
                        configuration.resultsFileLocalPath);
                    notifyCodeDeploy(
                        event.DeploymentId,
                        event.LifecycleEventHookExecutionId,
                        newmanError || newmanData?.run?.failures.length > 0 ? 'Failed' : 'Succeeded',
                        resolve,
                        reject);
                }
            );
        }
    );
}
