public with sharing class TestBulkActionBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Id jobId; // Monitored jobId
    public String scopeQuery; // Query coming from the action
    public Integer totalProgress = 0; // Current progress of the job

    public TestBulkActionBatch(Id jobId, String scopeQuery) {
        this.jobId = jobId;
        this.scopeQuery = scopeQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Just replace the Id with the expected columns for the our batch
        return Database.getQueryLocator(this.scopeQuery.replace('Id', 'Id, Name, StageName, CloseDate'));
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> opportunities) {
        if (opportunities.size() > 0) {
            for (Opportunity opp : opportunities) {
                opp.CloseDate += 1;
            }

            //We prepare the list of BulkActionError to keep track of save errors 
            List<gmpkg.BulkActionManager.BulkActionError> errorList = new List<gmpkg.BulkActionManager.BulkActionError>();
            List<Database.SaveResult> resultList = database.update(opportunities, false);
            for (Database.SaveResult res : resultList) {
                if (!res.isSuccess()) {
                    errorList.add(new gmpkg.BulkActionManager.BulkActionError(res.getId(), JSON.serialize(res.getErrors())));
                }
            }

            //If we have errors, we report them back to the monitor
            if (errorList.size() > 0) {
                gmpkg.BulkActionManager.reportErrors(this.jobId, errorList);
            }

            //We increase the progress and we report it back to the monitor
            this.totalProgress += opportunities.size();
            gmpkg.BulkActionManager.reportProgress(this.jobId, this.totalProgress);
        }
    }

    public void finish(Database.BatchableContext bc) {
        //At the end, we close the job
        gmpkg.BulkActionManager.closeJob(this.jobId);
    }
}