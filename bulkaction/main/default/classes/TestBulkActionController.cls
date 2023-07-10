public with sharing class TestBulkActionController {
    @AuraEnabled
    public static Id submitBulkAction(
        String gridLabel,
        String gridName,
        String actionLabel,
        String actionName,
        String query,
        String url
    ) {
        String countQuery = query.replaceAll('Id', 'count()');

        //Submit the job
        Id jobId = gmpkg.BulkActionManager.createJob(
            new gmpkg.BulkActionManager.BulkActionRequest(
                gridLabel,
                gridName,
                actionLabel,
                actionName,
                query,
                url,
                database.countQuery(countQuery)
            )
        );

        //Start the batch
        Database.executeBatch(new TestBulkActionBatch(jobId, query));
        return jobId;
    }
}