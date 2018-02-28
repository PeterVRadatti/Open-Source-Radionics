var aether = {};

console.log("AetherOne Version 1.0!");

$.fn.addClick = function (event) {
    this.unbind("click").click(event);
    return this;
};

/**
 * Important Note:
 * Do not misuse this application!
 * Do not harm anyone!
 * The intention build into this software is to heal and balance.
 * Only the mild-tempered will inherit the earth!
 */

/**
 * Another note: If you are reading the sourcecode and you know how to code, then help to improve this open source project on https://github.com/radionics/OpenSourceRadionics
 */

/**
 * TODO List
 * - https://jqueryvalidation.org/
 * - https://stackoverflow.com/questions/1962718/maven-and-the-jogl-library  (import processing libraries for serial communication via usb)
 */

aether.session = {
    time: $.now(),
    note: 'Protocol ready - Just hit <span class="badge badge-secondary">F5</span> (refresh) for a new Session',
    case: {}
};

aether.saveNewCase = function () {
    var caseObject = {name: $('#inputNewCaseName').val(), description: $('#inputNewCaseDescription').val(), createdTime: Date.now()};

    console.log(caseObject);

    aether.post('case', caseObject, function (persistedCase) {
        console.log(persistedCase);
        $('#formNewCase').lobiPanel("close");
        console.log('Set new case as selected with id = ' + persistedCase.id);
        $.get('case/selected/' + persistedCase.id, function(selectedCase){
            console.log(selectedCase.id);
        });
        aether.showSelectCaseForm(persistedCase);
    });
};

aether.saveNewTarget = function () {
    var target = {name: $('#inputNewTargetName').val(), description: $('#inputNewTargetDescription').val()};

    if ($('#pastedImage').attr('src') != null) {
        target.base64File = $('#pastedImage').attr('src').replace(/^data:image\/(png|jpg);base64,/, '');
        target.fileExtension = $('#pastedImage').attr('src').substr(11, 3);
    }

    aether.post('target', target, function (persistedTarget) {
        console.log(persistedTarget);
        $('#formNewTarget').lobiPanel("close");
        aether.showSelectTargetForm(persistedTarget);
    });
};

aether.post = function (url, data, callbackSuccess) {

    jQuery.ajax({
        type: "POST",
        url: url,
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        success: callbackSuccess,
        processData: false,
        cache: false,
        async: true
    });
};

aether.get = function (url, async, callbackSuccess) {

    jQuery.ajax({
        type: "GET",
        url: url,
        contentType: "application/json; charset=utf-8",
        success: callbackSuccess,
        processData: false,
        cache: false,
        async: async
    });
};

aether.showSelectCaseForm = function (caseObject) {
    aether.showForm("empty.html", "formSelectedCase" + caseObject.id, caseObject.name, false, function () {
        var caseContent = '';

        if (caseObject.description != null) {
            caseContent += '<p>' + caseObject.description + '</p>';
        }

        $("#formSelectedCase" + caseObject.id + "Content").append(caseContent);
    });
};

aether.showSelectTargetForm = function (target) {
    aether.showForm("empty.html", "formSelectedTarget" + target.id, target.name, false, function () {
        var targetContent = '';
        if (target.base64File != null) {
            targetContent += '<img src="data:image/png;base64,' + target.base64File + '">';
        }
        if (target.description != null) {
            targetContent += '<p>' + target.description + '</p>';
        }

        $("#formSelectedTarget" + target.id + "Content").append(targetContent);
    });
};

aether.showAddNewCaseForm = function () {
    aether.showForm("formNewCase.html", "formNewCase", "Add new case", false);
};

aether.showAddNewTargetForm = function () {
    aether.showForm("formNewTarget.html", "formNewTarget", "Add new target / patient", false);
};

/**
 * Inside the "formTemplate" (which contains lobi header and body) the template is embedded, replacing title and other data
 *
 * @param template
 * @param id
 * @param title
 * @param sortable
 * @param callbackAfterLoad
 */
aether.showForm = function (template, id, title, sortable, callbackAfterLoad) {
    $.get(template, function (data) {

        var form = aether.formTemplate.replace('#ID#', id).replace('#TITLE#', title).replace('#CONTENT#', data).replace('#ID-CONTENT#', id + "Content");
        $('#lobiContainerForAether').append(form);

        if (callbackAfterLoad != null) {
            callbackAfterLoad();
        }

        console.log('init lobiPanel for id = ' + id);

        $('#' + id).lobiPanel({
            minWidth: 300,
            minHeight: 300,
            maxWidth: 1000,
            maxHeight: 1000,
            draggable: true,
            sortable: sortable
        });
    });
};

aether.showAllCases = function () {

    $.get("case", function (cases) {

        console.log(cases);
        aether.cases = cases;
        aether.showForm("empty.html", "selectCaseFormContent", "Select a case", false, function () {

            var table = '<table id="selectCaseTable" class="table table-striped table-bordered table-hover"><tr><th>Name</th><th>Description</th></tr>';

            $.each(aether.cases.content, function (id, caseObject) {
                console.log(caseObject);
                table += '<tr><td data-id="' + caseObject.id + '">' + caseObject.name + '</td>';
                table += '<td>' + caseObject.description + '</td></tr>';
            });

            table += '</table>';

            $("#selectCaseFormContent").append(table);
            $("#selectCaseTable").unbind("click").click(function (event) {
                aether.selectCase($(event.target).data('id'));
            });
        });
    });
};

aether.showAllTargets = function () {
    $.get("target", function (targets) {

        console.log(targets);
        aether.targets = targets;
        aether.showForm("empty.html", "selectFormContent", "Select a target", false, function () {

            var table = '<table id="selectTargetTable" class="table table-striped table-bordered table-hover"><tr><th>Name</th><th>Description</th><th>Image</th></tr>';

            $.each(aether.targets.content, function (id, target) {
                console.log(target);
                table += '<tr><td data-id="' + target.id + '">' + target.name + '</td>';
                table += '<td>' + target.description + '</td>';

                var image = '';
                if (target.base64File != null) {
                    image = '<img width="128" src="data:image/png;base64,' + target.base64File + '">';
                }

                table += '<td>' + image + '</td></tr>';
            });

            table += '</table>';

            $("#selectFormContent").append(table);
            $("#selectTargetTable").unbind("click").click(function (event) {
                aether.selectTarget($(event.target).data('id'));
            });
        });
    });
};

aether.selectCase = function (caseId) {
    console.log('select case id = ' + caseId);
};

aether.selectTarget = function (targetId) {
    console.log('select target id = ' + targetId);
};

aether.init = function () {
    console.log("init AtherOne...");

    aether.checkServerStatus();
    aether.checkServerStatusThread();
    aether.checkHotbitsStatus();
    aether.checkHotbitsStatusThread();

    $.get("formTemplate.html", function (data) {
        aether.formTemplate = data;
    });

    $('#buttonNewCase').addClick(aether.showAddNewCaseForm);
    $('#buttonShowAllCases').addClick(aether.showAllCases);
    $('#buttonNewTarget').addClick(aether.showAddNewTargetForm);
    $('#buttonShowAllTargets').addClick(aether.showAllTargets);
    $('#protocolFooter').html(aether.getProtocolHTML());

    $('#buttonHelp').click(function () {
        $.get('help.html', function (helpData) {
            $('#modalDialog').html(helpData);
            $( "#modalDialog" ).dialog();
        });
    });
};

aether.getProtocolHTML = function () {
    var protocol = '<h3>Protocol</h3>';
    var dateTime = new Date(aether.session.time);


    aether.get('case/selected',false,function(selectedCase){
        console.log(selectedCase);

        if (selectedCase != null) {
            aether.session.case = selectedCase;
            protocol += '<p>Selected case : ' + selectedCase.name + '</p>';
        }
    });

    protocol += aether.getDateTimeFormatted(dateTime) + ' ' + aether.session.note;

    return protocol;
};

aether.getDateTimeFormatted = function (dateTime) {
    return $.datepicker.formatDate('yy-mm-dd', dateTime) + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds();
};

aether.checkHotbitsStatus = function () {
    $.get("hotbits-status", function (data) {
        console.log(data);
        if (data) {
            $('#statusHotbits').removeClass('btn-danger').addClass('btn-success');
        } else {
            $('#statusHotbits').removeClass('btn-success').addClass('btn-danger');
        }
    }).fail(function () {
        $('#statusHotbits').removeClass('btn-success').addClass('btn-danger');
    });
};

/**
 * The application could run on a server which uses a different hardware for the generation of TRNG and it could be plugged in or out
 */
aether.checkHotbitsStatusThread = function () {
    window.setInterval(function () {
        aether.checkHotbitsStatus();
    }, 60000);
};

aether.checkServerStatus = function () {
    $.get("ping", function (data) {
        if ("pong" == data) {
            $('#statusServer').removeClass('btn-danger').addClass('btn-success');
        }
    }).fail(function () {
        $('#statusServer').removeClass('btn-success').addClass('btn-danger');
    });
};

aether.checkServerStatusThread = function () {
    window.setInterval(function () {
        aether.checkServerStatus();
    }, 15000);
};