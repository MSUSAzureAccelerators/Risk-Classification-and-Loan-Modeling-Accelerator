![MSUS Solution Accelerator](./images/MSUS%20Solution%20Accelerator%20Banner%20Two_981.png)

# Risk Classification with Loan Modeling

## Business Objective

The objective of the Risk Classification with Loan Modeling project is to predict how much loan will be approved by the SBA & their registered lenders when a business applies for a loan through the SBA. 
  
The Small Business Administration (SBA) was founded in 1953 to assist small businesses in obtaining loans. Small businesses have been the primary source of employment in the United States. Helping small businesses help with job creation, which reduces unemployment. Small business growth also promotes economic growth. One of the ways the SBA helps small businesses is by guaranteeing bank loans. This guarantee reduces the risk to banks and encourages them to lend to small businesses. If the loan defaults, the SBA covers the amount guaranteed, and the bank suffers a loss for the remaining balance.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/SBA%20Loan%20High%20Level.png?raw=true)

The SBA works with lenders to provide loans to small businesses. The agency doesn’t lend money directly to small business owners. Instead, it sets guidelines for loans made by     its partnering lenders, community development organizations, and micro-lending institutions. The SBA reduces risk for lenders and makes it easier for them to access capital.       That makes it easier for small businesses to get loans.
  
Loans guaranteed by the SBA range from small to large and can be used for most business purposes, including long-term fixed assets and operating capital. Some loan programs set   restrictions on how you can use the funds, so check with an SBA-approved lender when requesting a loan. Your lender can match you with the right loan for your business needs.

## What you need to know about SBA Loan

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/What%20you%20need%20to%20know%20about%20Loan.png?raw=true)

## Business Loan Eligibility requirements

Lenders and loan programs have unique eligibility requirements. In general, eligibility is based on what a business does to receive its income, the character of its ownership,     and where the business operates. Normally, businesses must meet size standards, be able to repay, and have a sound business purpose. Even those with bad credit may qualify for     startup funding. The lender will provide you with a full list of eligibility requirements for your loan.

 Following are the baseline eligibility requirements:
    # Be a for-profit business
      The business is officially registered and operates legally.
    # Do business in the U.S.
      The business is physically located and operates in the U.S. or its territories.
    # Have invested equity
      The business owner has invested their own time or money into the business.
    # Exhaust financing options
      The business cannot get funds from any other financial lender.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/business-loan-factors-1.jpg?raw=true)

## Business Loans for exporters

Most U.S. banks view loans for exporters as risky. This can make it harder for you to get loans for things like day-to-day operations, advance orders with suppliers, and debt refinancing. That’s why the SBA created programs to make it easier for U.S. small businesses to get export loans.

## The Business Loan Data Set (Reference : www.kaggle.com)

The original data set is from the U.S.SBA loan database, which includes historical data from 1987 through 2014 (899,164 observations) with 27 variables. The data set includes   information on whether the loan was paid off in full or if the SMA had to charge off any amount and how much that amount was. The data set used is a subset of the original       set. It contains loans about the Real Estate and Rental and Leasing industry in California. This file has 2,102 observations and 35 variables. The column Default is an integer   of 1 or zero, and I had to change this column to a factor.
  
            Variable Name			Description
            LoanNr_ChkDgt			    Identifier Primary key
            Name	        		    Borrower name
            City	        		    Borrower city
            State	        		    Borrower state
            Zip	        		      Borrower zip code
            Bank	        		    Bank name
            BankState			        Bank state
            NAICS	        		    North American industry classification system code
            ApprovalDate			    Date SBA commitment issued
            ApprovalFY			      Fiscal year of commitment
            Term	        		    Loan term in months
            NoEmp	        		    Number of business employees
            NewExist			        1 = Existing business, 2 = New business
            CreateJob			        Number of jobs created
            RetainedJob			      Number of jobs retained
            FranchiseCode			    Franchise code, (00000 or 00001) = No franchise
            UrbanRural			      1 = Urban, 2 = rural, 0 = undefined
            RevLineCr			        Revolving line of credit: Y = Yes, N = No
            LowDoc Loan Program 	Y = Yes, N = No
            ChgOffDate			      The date when a loan is declared to be in default
            DisbursementDate		  Disbursement date
            DisbursementGross		  Amount disbursed
            BalanceGross			    Gross amount outstanding
            MIS_Status			      Loan status charged off = CHGOFF, Paid in full =PIF
            ChgOffPrinGr			    Charged-off amount
            GrAppv				        Gross amount of loan approved by bank
            SBA_Appv			        SBA’s guaranteed amount of approved loan

## Technical Stack

  The Business Loan Modeling project will use Azure Synapse Analytics, Azure DataLake Gen2, Azure Machine Learning and PowerBI.
  
## Architecture Overview

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/HighLevelReferenceArchitecture.JPG?raw=true)
![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/SynapsePipeComponents.JPG?raw=true)
![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/EndToEndDI_Analytics_Components.JPG?raw=true)

## Implementation Detail

Goal is to train ML model on the SBA loan data and then build a Data engineering pipeline which can further process one or many new loan requests coming in as either API and/or Batch requests. Azure Synapse Pipe from Azure Synapse Workspace is used for consuming data from third party (same can be achieved by leveraging Azure Data Factory). Azure Synapse pipeline was used for multiple purpose:

1. Data Ingestion (Third Party API to ADLS Gen2)
2. Orchestration

Azure Machine Learning service was used for building and training Machine Learning (ML) model. Once a model was built, then Azure Synapse Pipeline was levaraged for orchestrating it call Azure ML Batch pipeline to score on a new SBI loan data requests.

Stages to accomplish goal:
Stage 1: Build a ML model
To build an ML model, we need to first cleanse the public data to a conformed state which we can feed to train a machine learning model.
1)	Ingesting the SBA data from a Source (Typically this would be a partner or data provider who provides a storage account\FTP site to access this data), Copy Data activity in the below Synapse pipeline will be able to copy the data from a remote partner to a local storage account. For this demo we are copying binary files from “sbasourcerawdata” to “sba” containers

2)	Once we get the data(CSV file) in our scenario, We need to cleanse this data to shape it into a structure which is good enough to train a Machine learning model. For that purpose, we are using a Dataflow activity within Synapse pipelines, where we can shape and structure the original raw data. Dataflow uses Synapse Spark clusters in the background to execute these transformations and your training data even if it is in TB’s can be quickly processed and cleansed. For this demo, the source of the Dataflows would be “sba” container and the sink of the dataflow would land it in “sbacurated” container.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step1-Dataload.png?raw=true)

Dataflow activity looks like the below structure where we define datatypes and formats, Clean unnecessary characters like “$” values, Remove unnecessary columns etc which is not needed to train the model etc. Finally, the output will be written a Dataset which is cleansed and ready to be fed into Azure Machine learning for training a model.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step2-Datacuration.png?raw=true) 

3)	Build an Azure ML training pipeline, there are multiple ways to achieve this like using Python notebooks, Designer and Auto ML, but the easiest would be to use the Azure ML designer where you get a canvas to drag and drop tasks to build a training pipeline.

We build the following pipeline to train a model using this training data which we have cleansed in the previous step. We add the “sbacurated” container in the previous stage as a dataset for Azure ML workspace. This dataset can now be used in various experiments.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step3-AzureML.png?raw=true)

The curated data which we processed in the previous steps using Dataflows is registered as a Dataset in Azure ML. That dataset which is shown as “sbacurated” acts as the training data, It goes through few steps like Splitting the data, filtering unnecessary columns etc and finally Train a model. We are using Boosted decision Tree regression algorithm here but you can try different regression algorithms to compare the accuracy etc.
Once you are satisfied with the Model metrics like Accuracy, Spearman correlation etc, the last step of the model is to Export out the Scored data to a CSV file, This file is getting saved in the “amloutput” on the storage container and finally publishing this as a Batch pipeline.
Here is a Batch Pipeline which is shown after getting published. This is the Batch Inference pipeline which comes with an endpoint. This will be executed as part of the Synapse Pipeline for doing batch scoring on new SBA loan requests as part of a nightly schedule as explained in next stage.
 
![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step4-AzureML.png?raw=true)

Stage 2: Build a Synapse Pipeline to do daily Batch Inferencing on new SBA loan requests 
As the ML model\Batch inference pipeline is already built in the previous step, now we need to execute a Synapse Pipeline on a daily schedule, which will retrieve all the new data, cleanse it to make sure that there are no data consistency issues and finally call the Azure ML pipeline which we have built in the earlier stage. Step 1 and 2 in this stage are the same as the earlier stage and hence not repeating them for brevity purposes. You can reuse the same pipeline which you built earlier to add the last activity to execute a Machine learning pipeline as shown below.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step5-AzureSynapsePipeline.png?raw=true)

The last step of the Syanpse pipeline, calls an Azure ML pipeline which we have built in the earlier stage. This step will trigger the Batch inference pipeline in Azure ML.
From an Azure ML side, the Batch Inference run would look something like the below image which confirms that all the stage completed. successfully

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step6-AzureML.png?raw=true)

The last step of the process would export the data out to “amloutput” storage account which contains the final CSV which is scored by the Azure ML batch inference pipeline.
Here is a screenshot of all the containers in the storage account.  Final CSV file gets stored in the amloutput container.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step7-AzureML.png?raw=true)

Best part of Azure Synapse is the new Synapse Serverless SQL which has an option to query this data natively from within the filesystem.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step8-AzureML.png?raw=true)

Finally, you can run a query to see all the scored amounts for different SBA requests.

![name-of-you-image](https://github.com/ketsha/Business-Loan-Modeling/blob/main/images/Step9-AzureSynapseanalytics.png?raw=true) 

You can create a view on top of this query and any client which can talk to SQL can run this query to view all the Scored data as a simple SELECT query.

During Stage 1, we could have also deployed a Real time Inference pipeline which would deploy the API to an existing Kubernetes clusters. Any application can pass parameters to this API with different values and in turn get a response with the Scored label value. This is ideal for interactive applications when a decision needs to be taken immediately. 

## Video series

[Business Objective](https://github.com/MSUSSolutionAccelerators/Risk-Classification-and-Load-Modeling-Solution-Accelerator/blob/main/video/objective.mp4)

[Introduce Synapse workspace and provisioned resources](https://user-images.githubusercontent.com/22504173/112752400-d66dee00-8fa0-11eb-83e6-b1279449e9ba.mp4) 

[Raw Data ingestion - Synapse Pipelines](https://user-images.githubusercontent.com/22504173/112752398-d40b9400-8fa0-11eb-8680-1a2c1c67fba3.mp4) 

[Data cleansing\transformation - Synapse Dataflows](https://user-images.githubusercontent.com/22504173/112752404-d8d04800-8fa0-11eb-9a9e-f477564ec373.mp4) 

[Load data into Synapse Spark for ML](https://user-images.githubusercontent.com/22504173/112752394-d110a380-8fa0-11eb-9de6-1d6002340819.mp4) 

[Deploy a model in Synapse Spark using Azure ML - Automated ML](https://user-images.githubusercontent.com/22504173/112752387-cc4bef80-8fa0-11eb-8f52-294e76ccf4be.mp4) 

[Load and Score data in Synapse Dedicated SQL pools](https://user-images.githubusercontent.com/22504173/112752381-c81fd200-8fa0-11eb-879c-3ec99e6cb1fd.mp4)

## Deployment

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMSUSSolutionAccelerators%2FRisk-Classification-and-Load-Modeling-Solution-Accelerator%2Fmain%2FTemplateForWorkspace.json )

## License

Copyright (c) Microsoft Corporation

All rights reserved.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

