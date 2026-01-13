var childWindow;

$(document).ready(function () {
    $('#condition-statement-type').change(conditionTypeChangeHandler);
    $('#condition-statement-props').change(conditionPropertyChangeHandler);

    displayProperFieldsIfErrors();
});

function conditionTypeChangeHandler(e) {
    e.preventDefault();

    var selectedType = $(this).val();
    if (selectedType != 7) { //date
        $('.from-time').hide();
        $('.to-time').hide();
        $('.from-date').hide();
        $('.to-date').hide();
        $('.exact-day').hide();
        $('.value').find('input').val('');
        $('.value').show();
        $('.operator-type').show();
        $('.month-from-day').hide();
        $('.month-to-day').hide();
    }
    else {
        $('.operator-type').hide();
        $('.value').hide();
    }

    $.ajax({
        url: '/Admin/NopTechCondition/GetConditionPropertiesForConditionType',
        type: 'GET',
        data: { typeId: selectedType },
        success: function (response) {
            var propSelect = $('#condition-statement-props select');
            if (propSelect.length == 0) {
                propSelect = $('#condition-statement-props');
            }
            propSelect.empty();

            $('#condition-statement-value').children().first().remove();
            var newInput = $('<input class="form-control" asp-for="Value" name="Value"/>');
            $('#condition-statement-value').append(newInput);

            $.each(response.data, function (index, prop) {
                var option = $('<option></option>').attr('value', prop.Value).text(prop.Text);

                if (prop.Value === "-1") {
                    option.prop('disabled', true);
                    option.prop('text', "Please, select property");
                }
                propSelect.append(option);
            });

            var selectedValue = "-1";
            propSelect.find('option[value="' + selectedValue + '"]').prop('selected', true);
            $('#condition-statement-props').attr('disabled', false);
        },
        error: function () {
            alert('An error occurred while fetching the years.');
        }
    });
}

function conditionPropertyChangeHandler(e) {
    e.preventDefault();

    var selectedProperty = $(this).find(':selected').val();
    var conditionType = $('#condition-statement-type').val();

    $.ajax({
        url: '/Admin/NopTechCondition/GetOperatorTypesAndValuesForProperty',
        type: 'GET',
        data: { propertyId: selectedProperty, conditionType: conditionType },
        success: function (response) {
            var operator = $('#condition-statement-operator');
            operator.empty();

            $.each(response.operators, function (index, prop) {
                var option = $('<option></option>').attr('value', prop.Value).text(prop.Text);
                operator.append(option);
            });

            var editorContainer = $('#condition-statement-value');

            if (response.values.length > 0) {
                var newSelect = $('<select class="form-control" asp-for="Value" name="Value"></select>');

                $.each(response.values, function (index, prop) {
                    var option = $('<option></option>').attr('value', prop.Value).text(prop.Text);
                    newSelect.append(option);
                });

                editorContainer.empty().append(newSelect);

                $('#condition-property-name').val(specificationName);
            }
            else {
                if (conditionType == 7) {
                    $('.from-time').show();
                    $('.to-time').show();

                    if (selectedProperty == 21) {  //exact day
                        $('.exact-day').show();
                        $('.from-date').hide();
                        $('.to-date').hide();
                        $('.month-from-day').hide();
                        $('.month-to-day').hide();
                    }
                    else if (selectedProperty == 18) {   //every meonth
                        $('.month-from-day').show();
                        $('.month-to-day').show();
                        $('.exact-day').hide();
                        $('.from-date').hide();
                        $('.to-date').hide();
                    }
                    else if (selectedProperty == 31) {   //between 2 dates
                        $('.from-date').show();
                        $('.to-date').show();
                        $('.month-from-day').hide();
                        $('.month-to-day').hide();
                        $('.exact-day').hide();
                        $('.from-time').hide();
                        $('.to-time').hide();
                    }
                    else {
                        $('.exact-day').hide();
                        $('.from-date').hide();
                        $('.to-date').hide();
                        $('.month-from-day').hide();
                        $('.month-to-day').hide();
                    }

                    
                    $('.value').hide();
                }
                else {
                    $('.from-time').hide();
                    $('.to-time').hide();
                    $('.exact-day').hide();
                    $('.value').show();
                    $('.operator-type').show();

                    var newInput = $('<input class="form-control" asp-for="Value" name="Value"/>');
                    editorContainer.empty().append(newInput);
                }
            }

            $('#condition-statement-operator').attr('disabled', false);
        },
        error: function () {
            alert('An error occurred while fetching the years.');
        }
    });
}

function addConditionGroup() {
    var conditionId = $('#condition-id').val();

    $.ajax({
        url: '/Admin/NopTechCondition/AddConditionGroup',
        method: 'POST',
        data: { conditionId: conditionId },
        success: function (result) {
            // Handle the success response from the server if needed
            location.reload();
        },
        error: function (xhr, status, error) {
            // Handle the error if the request fails
            console.error('AJAX request failed', error);
        }
    });
}

function displayProperFieldsIfErrors() {
    var conditionTypeValue = $('#condition-statement-type option:selected').val();
    var conditionPropertyValue = $('#condition-statement-props option:selected').val();

    if (conditionTypeValue == 7) {
        $('.from-time').show();
        $('.to-time').show();

        if (conditionPropertyValue == 18) { //every month
            $('.month-from-day').show();
            $('.month-to-day').show();

            $('.exact-day').hide();
            $('.from-date').hide();
            $('.to-date').hide();
        }
        else if (conditionPropertyValue == 21) { // exactday
            $('.exact-day').show();

            $('.month-from-day').hide();
            $('.month-to-day').hide();
            $('.from-date').hide();
            $('.to-date').hide();
        }
        else if (conditionPropertyValue == 31) { //between dates
            $('.from-date').show();
            $('.to-date').show();

            $('.month-from-day').hide();
            $('.month-to-day').hide();
            $('.exact-day').hide();

            $('.from-time').hide();
            $('.to-time').hide();
        }
    }
}

function deleteGroup(a) {
    var confirm = window.confirm("Delete condition group?");
    if (confirm) {
        $.ajax({
            url: '/Admin/NopTechCondition/DeleteConditionGroup',
            method: 'POST',
            data: { groupId: a },
            success: function (result) {
                location.reload();
            },
            error: function (xhr, status, error) {
                console.log('AJAX request failed', error);
            }
        });
    }
    return;
}

function updateDefaultCondition(a) {
    let conditionGroupId = $('#condition-group-id').val();

    var postData = {
        Id: a,
        Name: $('#condition-name').val(),
        IsActive: $('#condition-active').prop('checked'),
        StateId: $('#condition-state').val(),
        ConditionGroupId: conditionGroupId
    };

    $.ajax({
        url: '/Admin/NopTechCondition/UpdateDefaultCondition',
        method: 'POST',
        data: postData,
        success: function (result) {
            location.reload();
        },
        error: function (xhr, status, error) {
            console.log('AJAX request failed', error);
        }
    });
}

function addRecord(a) {
    //dual monitor fix popup to take correct window screen values
    let dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : window.screenX;
    let dualScreenTop = window.screenTop != undefined ? window.screenTop : window.screenY;

    const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var popupWidth = 700;
    var popupHeight = 400;

    let systemZoom = width / window.screen.availWidth;
    let left = (width - popupWidth) / 2 / systemZoom + dualScreenLeft;
    let top = (height - popupHeight) / 2 / systemZoom + dualScreenTop;

    var url = '/Admin/NopTechCondition/AddRecordToConditionGroup/' + a;
    childWindow = window.open(url, 'childWindow', 'width=' + popupWidth + ',height=' + popupHeight + ',resizable=yes,left=' + left + ',top=' + top + ',location=no');
}

function editRecord(data, type, row, meta) {
    //dual monitor fix popup to take correct window screen values
    let dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : window.screenX;
    let dualScreenTop = window.screenTop != undefined ? window.screenTop : window.screenY;

    const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var popupWidth = 700;
    var popupHeight = 400;

    let systemZoom = width / window.screen.availWidth;
    let left = (width - popupWidth) / 2 / systemZoom + dualScreenLeft;
    let top = (height - popupHeight) / 2 / systemZoom + dualScreenTop;

    let url = '/Admin/NopTechCondition/EditConditionGroupRecord/' + data;
    childWindow = window.open(url, 'childWindow', 'width=' + popupWidth + ',height=' + popupHeight + ',resizable=yes,left=' + left + ',top=' + top + ',location=no');
}