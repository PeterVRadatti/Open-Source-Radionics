var aether = {};

console.log("AetherOne Version 1.0!");

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

aether.init = function () {
    console.log("init AtherOne...");

    aether.checkServerStatus();
    aether.checkServerStatusThread();
    aether.checkHotbitsStatus();
};

aether.checkHotbitsStatus = function () {
    $.get("hotbits-status", function (data) {
        console.log(data);
        if ("" == data) {
            $('#statusHotbits').removeClass('btn-danger').addClass('btn-success');
        }
    }).fail(function () {
        $('#statusHotbits').removeClass('btn-success').addClass('btn-danger');
    });
};

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