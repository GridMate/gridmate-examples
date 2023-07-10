public with sharing class TestBulkActionBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Id jobId;
    public String scopeQuery;
    public Integer totalProgress = 0;

    public TestBulkActionBatch(Id jobId, String scopeQuery) {
        this.jobId = jobId;
        this.scopeQuery = scopeQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.scopeQuery.replace('Id', 'Id, Name, StageName, CloseDate'));
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> opportunities) {
        if (opportunities.size() > 0) {
            for (Opportunity opp : opportunities) {
                opp.CloseDate += 1;
            }

            List<gmpkg.BulkActionManager.BulkActionError> errorList = new List<gmpkg.BulkActionManager.BulkActionError>();
            List<Database.SaveResult> resultList = database.update(opportunities, false);
            for (Database.SaveResult res : resultList) {
                if (!res.isSuccess()) {
                    errorList.add(new gmpkg.BulkActionManager.BulkActionError(res.getId(), JSON.serialize(res.getErrors())));
                }
            }

            if (errorList.size() > 0) {
                gmpkg.BulkActionManager.reportErrors(this.jobId, errorList);
            }

            this.totalProgress += opportunities.size();
            gmpkg.BulkActionManager.reportProgress(this.jobId, this.totalProgress);
        }
    }

    public void finish(Database.BatchableContext bc) {
        gmpkg.BulkActionManager.closeJob(this.jobId);
    }
}