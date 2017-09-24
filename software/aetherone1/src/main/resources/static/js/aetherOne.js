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
    note: 'Protocol ready - Just hit <span class="badge badge-secondary">F5</span> (refresh) for a new Session'
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

aether.showAddNewTargetForm = function () {
    aether.showForm("formNewTarget.html", "formNewTarget", "Add new target / patient", false);
};

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

aether.showAllTargets = function () {
    $.get("target", function (targets) {

        aether.targets = targets;
        aether.showForm("empty.html", "selectFormContent", "Select a target", false, function () {

            var table = '<table id="selectTargetTable" class="table table-striped table-bordered"><tr><th>Name</th><th>Description</th><th>Image</th></tr>';

            $.each(aether.targets, function (id, target) {
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