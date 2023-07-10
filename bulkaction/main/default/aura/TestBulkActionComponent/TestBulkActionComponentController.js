({
    handleSubmit: function (component, event, helper) {
        component.set('v.isWorking', true);

        //Submit the action to the Salesforce
        let action = component.get('c.submitBulkAction');
        action.setParams({
            gridLabel: component.get('v.gridLabel'),
            gridName: component.get('v.gridName'),
            actionLabel: component.get('v.actionLabel'),
            actionName: component.get('v.actionName'),
            query: component.get('v.query'),
            url: window.location.href
        });

        action.setCallback(this, function (res) {
            component.set('v.isWorking', false);
            if (res.getState() === 'SUCCESS') {
                //Publish the JobId for the monitor
                let bulkActionPublisher = component.find('bulkActionPublisher');
                bulkActionPublisher.publish(res.getReturnValue());

                //Show a toast for the end user
                let toastEvent = $A.get('e.force:showToast');

                toastEvent
                    .setParams({
                        title: 'Success',
                        type: 'success',
                        message: 'Action Executed Successfully'
                    })
                    .fire();

                component
                    .getEvent('onsuccess')
                    .setParams({
                        action: 'BulkActionExecuted'
                    })
                    .fire();

                //Close the modal
                component.find('overlayLib').notifyClose();
            } else if (res.getState() === 'ERROR') {
                helper.handleServerErr(res);
            }
        });

        $A.enqueueAction(action);
    },
    handleCancel: function (component, event, helper) {
        component
            .getEvent('oncancel')
            .setParams({
                action: 'MassAssignCancelled'
            })
            .fire();

        component.find('overlayLib').notifyClose();
    }
});