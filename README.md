# ais-apim-odata-reactjs
This is a repository on how to import an SAP ODATA API in Azure API Management and link it with a Static Web App to consume the SAP ODATA API.

## Build Status

| GitHub Action | Status |
| ----------- | ----------- |
| Build | [![Build](https://github.com/pascalvanderheiden/ais-apim-odata-reactjs/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/pascalvanderheiden/ais-apim-odata-reactjs/actions/workflows/build.yml) |
| Release | [![Release](https://github.com/pascalvanderheiden/ais-apim-odata-reactjs/actions/workflows/release.yml/badge.svg)](https://github.com/pascalvanderheiden/ais-apim-odata-reactjs/actions/workflows/release.yml) |

## About

This repository contains a ReactJS application, running in [Azure Static Web Apps](https://docs.microsoft.com/en-us/azure/static-web-apps/overview), that consumes the SAP ODATA API via [Azure API Management](https://docs.microsoft.com/en-us/azure/api-management/overview). All Azure services are deployed via Bicep templates and the ReactJS application is deployed via a GitHub Action, which will be available after the Static Web App has been deployed. 

I got most of my Bicep examples from [here](https://github.com/Azure/bicep/tree/main/docs/examples).

Because I'm not a ReactJS developer, I used ChatGPT to generate the code and link it to SAP ODATA API via API Management. I've included the generated code in this repository, so you can see how it works. 

Hope you find this useful!

## Architecture

![ais-apim-odata-reactjs](docs/images/arch.png)

## Prerequisites

* Install [Visual Studio Code](https://code.visualstudio.com/download)
* Install [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) Extension for Visual Studio Code.
* Install [Bicep Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) Extension for Visual Studio Code.
* Install [NodeJS with NPM](https://nodejs.org/en/download/)

## SAP ODATA APIs

I've used a sample SAP ODATA metadata file and converted it into an OpenAPI specification with [this tool](https://convert.odata-openapi.net/). You can find the specification in [this folder](./deploy/release/apim/odata).

## Deploy with Github Actions

* Fork this repository

When you fork the repository, delete the generated CI/CD GitHub Action, as this will be generated via Bicep for you and made specific for your deployment.

* Generate a repository token for the Azure Static Web App Deployment

The Azure Static Web App will be linked to this repository for the source code of the app. To link the repository, you need to generate a personal access token (PAT) with the repo scope. For more information, see [Create a personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

Copy the generated token.

In the repository go to 'Settings', on the left 'Secrets', 'Actions'.
And pass the json output in the command used above into the secret 'REPO_TOKEN'.

* Generate a Service Principal

```ps1
az ad sp create-for-rbac -n <name_sp> --role Contributor --sdk-auth --scopes /subscriptions/<subscription_id>
```

Copy the json output of this command.

In the repository go to 'Settings', on the left 'Secrets', 'Actions'.
And pass the json output in the command used above into the secret 'AZURE_CREDENTIALS'.

* Update GitHub Secrets for customizing your deployment

In the repository go to 'Settings', on the left 'Secrets', 'Actions'.

The following secrets need to be created:

* AZURE_CREDENTIALS (see above)
* REPO_TOKEN (see above)
* AZURE_SUBSCRIPTION_ID
* LOCATION
* PREFIX
* API_USERNAME (username for the SAP backend)
* API_PASSWORD (username for the SAP backend)

You can run the Build GitHub Action manually by going to 'Actions' and clicking on the 'Run workflow' button. The Release GitHub Action will be triggered automatically after the Build GitHub Action has been completed.

### Static Web App will deploy its own GitHub Action for updating the Static Web App

By the Release pipeline the Static Web App will be deployed. This will also deploy a GitHub Action to the repository to update the Static Web App. Normally the Static Web App is the only deployment for a repository, but in this case everything is included in this repository, and the source is pointing to a specific folder. You can update the trigger for the CI/CD GitHub Action to only be triggered in case of changes in this specific folder. Just add this to the GitHub Action:

```yml
on:
  push:
    branches:
      - main
    paths:
      - 'deploy/release/app/react-odata-app/**'
```

## Create a ReactJS app with ChatGPT

I've used [ChatGPT](https://chatgpt.com/) to generate the ReactJS code. You can find the generated code in [this folder](./deploy/release/app/react-odata-app).

First I asked ChatGPT: How do I create a reactjs app?

![ais-apim-odata-reactjs](docs/images/how_do_create_a_reactjs_app.gif)

```ps1
npm install -g create-react-app
npx create-react-app <app_name>
cd <app_name>
npm start
```
I just pasted these commands in the terminal in Visual Studio Code.

![ais-apim-odata-reactjs](docs/images/vscode_create_reactjs_app.gif)

And, voila! You have a ReactJS app running locally.

![ais-apim-odata-reactjs](docs/images/react_app_runninggif)

Then I asked ChatGPT: Generate a reactjs app which shows a list of BusinessPartners from this API <my static web app url> and show the id and name in a list.

It gave me a spot on answer, and I just copied the code and pasted it in the App.js file.

![ais-apim-odata-reactjs](docs/images/chatgpt_generate_code_for_api.png)

Commited the code to the repository and pushed it to GitHub. The GitHub Action deployed the ReactJS app to the Static Web App in Azure. Amazing!

## Testing

I've included a [tests.http]((./tests.http)) file with relevant tests you can perform on the API Management Instance, to check if your deployment is successful. For the tests I created a seperate Product Group in API Management, so you can easily remove it after testing.

## Remove the APIM Soft-delete

If you deleted the deployment via the Azure Portal, and you want to run this deployment again, you might run into the issue that the APIM name is still reserved because of the soft-delete feature. You can remove the soft-delete by using this script:

```ps1
$subscriptionId = "<subscription_id>"
$apimName = "<apim_name>"

.\deploy\del-soft-delete-apim.ps1 -subscriptionId $subscriptionId -apimName $apimName
```

## Like this project?

If you like this project, please give it a star. If you have any questions, please create an issue.
Thanks for reading!