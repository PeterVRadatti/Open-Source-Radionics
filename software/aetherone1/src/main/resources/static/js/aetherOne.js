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
 * - https://github.com/danielm/uploader/
 * - https://jqueryvalidation.org/
 * - https://stackoverflow.com/questions/1962718/maven-and-the-jogl-library  (import processing libraries for serial communication via usb)
 */

aether.saveNewTarget = function () {
    var target = {name: $('#inputNewTargetName').val()};

    if ($('#pastedImage').attr('src') != null) {
        target.base64File = $('#pastedImage').attr('src').replace(/^data:image\/(png|jpg);base64,/, '');
        target.fileExtension = $('#pastedImage').attr('src').substr(11,3);
    }

    console.log(target);

    aether.post('target', target, function () {
        $('#formNewTarget').lobiPanel("close");
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

aether.showSelectTargetForm = function () {
    aether.showForm("formSelect.html", "formNewTarget", "Add new target / patient", false);
};

aether.showAddNewTargetForm = function () {
    aether.showForm("formNewTarget.html", "formNewTarget", "Add new target / patient", false);
};

aether.showForm = function (template, id, title, sortable, callbackAfterLoad) {
    $.get(template, function (data) {

        var form = aether.formTemplate.replace('#ID#', id).replace('#TITLE#', title).replace('#CONTENT#', data);
        $('#lobiContainerForAether').append(form);

        if (callbackAfterLoad != null) {
            callbackAfterLoad();
        }

        $('#' + id).lobiPanel({
            minWidth: 300,
            minHeight: 300,
            maxWidth: 1000,
            maxHeight: 1000,
            draggable: true,
            sortable: sortable
        }).pin();
    });
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