({
    handleServerErr: function (res) {
        let errors = res.getError();

        let errList = null;
        if (errors[0] && errors[0].message) {
            try {
                errList = JSON.parse(errors[0].message).map((err) => {
                    return { message: `${err.UID} : ${err.message}` };
                });
            } catch (e) {
                errList = [{ message: errors[0].message }];
            }
        }
        if (errors[0] && errors[0].pageErrors) {
            errList = [{ message: errors[0].pageErrors[0].message }];
        }

        console.error(errors);
        return errList;
    }
});