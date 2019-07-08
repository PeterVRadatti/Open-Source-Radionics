var aether = {};

aether.init = function () {
    $.get('protocol', function (data) {

        data.forEach(function (rate) {
            console.log(rate);
            var row = '<tr fileName="' + rate.fileName + '"><td>' + rate.dateTimeString + '</td><td>' + rate.input + '</td><td>' + rate.output + '</td><td>' + rate.level + '</td><td>' + rate.ratio + '</td><td>' + rate.synopsis + '</td></tr>';
            $('#protocolTable').append(row);
        })
    });

    $('#protocolTable').delegate('tr', 'click', function () {
        console.log($(this).attr('fileName'));

        var id = $(this).attr('fileName').split("_")[1];

        $.get('protocol/' + id, function (protocol) {

            $('#spanProtocolFileName').html(protocol.input);

            var database = protocol.database != null ? protocol.database : '';
            var output = protocol.output != null ? protocol.output : '';
            var details = '<pre>' + database + '\n' + output + '\n' + protocol.synopsis + '</pre>';
            details = details.replace('(','\n(');
            var resultTable = details + '<table class="table table-bordered"><thead><th>Rate</th><th>Energetic Level</th></thead><tbody>';

            protocol.result.forEach(function(rate) {

                console.log(rate);
                var name = Object.keys(rate)[0];
                var value = rate[name];

                resultTable += '<tr><td>' + name + '</td><td>' + value + '</td></tr>';
            });

            resultTable += '</tbody></table>';

            $('#protocolDialogBody').html(resultTable);
            $('#protocolModalDialog').modal('show');
        });
    });
};

aether.init();