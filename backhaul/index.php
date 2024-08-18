<?php
header('Content-Type: application/json');

$arrContextOptions = [
    'ssl' => [
        'verify_peer' => false,
        'verify_peer_name' => false,
    ],
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($_POST['id']) ? $_POST['id'] : 'KOSONGANNUL';
    $endPoint = isset($_POST['endPoint']) ? (strval($_POST['endPoint'])) : 'KOSONGAN';
    $port = isset($_POST['port']) ? strval($_POST['port']) : 'KOSONGAN';

    $username = isset($_POST['username']) ? $_POST['username'] : 'iptInstall1zz';
    $pass = isset($_POST['pass']) ? $_POST['pass'] : 'NOC%20TELEGLOBALzzz';

    $auth = 'username=$username&password=$pass';
    $link = "202.55.175.235:8443/api/getsensordetails.json?id=$id&username=NOC%20TELEGLOBAL&password=iptInstall";

    $getData = @file_get_contents("https://$endPoint/api/getsensordetails.json?id=$id&username=$username&password=$pass", false, stream_context_create($arrContextOptions));
    $parsedData = json_decode($getData, true);


    $sensorName = $parsedData['sensordata']['name'];
    $sensorVal = $parsedData['sensordata']['lastvalue'];
    $checkStr = "/traffic/i";

    $splitSenVal = preg_split("/ /", "$sensorVal");

    if (preg_match('/Mb/i', $splitSenVal[1])) {
        $replaceSenVal = str_replace(',', '.', $splitSenVal[0]);

        $formatSenVal =  (float) $replaceSenVal * 1000;
        $formatSenVal =  number_format($formatSenVal, 0, '.', '.');;
        $finalSenVal =   "$formatSenVal kbit/s (Traffic Total)";
    } else {
        $finalSenVal = $sensorVal;
    }

    if (!empty($id) && $sensorName != '' && $sensorVal != '') {
        if (preg_match($checkStr, $sensorVal)) {
            $data = [
                'sensordata' => [
                    'name' => $parsedData['sensordata']['name'],
                    'value' => $finalSenVal,
                ],
            ];
        } else {
            $data = [
                'sensordata' => [
                    'name' => "{$parsedData['sensordata']['name']} {$parsedData['sensordata']['parentdevicename']}",
                    'value' => $parsedData['sensordata']['lastvalue'],

                ],
            ];
        }
    } else {
        $data = ['sensordata' => null];
    }

    $jsonData = json_encode($data);
    echo $jsonData;
}

// // Backhaul IBS / MTD BATAM RUNGKUT
// $konten3 = @file_get_contents("https://202.55.175.235:8443/api/getsensordetails.json?id=25674&username=NOC%20TELEGLOBAL&password=iptInstall1", false, stream_context_create($arrContextOptions));
// $data3 = json_decode($konten3, true);

// $konten4 = @file_get_contents("https://202.55.175.235:8443/api/getsensordetails.json?id=25673&username=NOC%20TELEGLOBAL&password=iptInstall1", false, stream_context_create($arrContextOptions));
// $data4 = json_decode($konten4, true);

// $konten5 = @file_get_contents("https://202.55.175.235:8443/api/getsensordetails.json?id=  &username=NOC%20TELEGLOBAL&password=iptInstall1", false, stream_context_create($arrContextOptions));
// $data5 = json_decode($konten5, true);

// // Backhaul MTD BINTARO JATINEGARA
// $konten1 = @file_get_contents("https://202.55.175.235:8443/api/getsensordetails.json?id=24173&username=NOC%20TELEGLOBAL&password=iptInstall1", false, stream_context_create());
// $data1 = json_decode($konten1, true);

// $konten2 = file_get_contents("https://202.55.175.235:8443/api/getsensordetails.json?id=25032&username=NOC%20TELEGLOBAL&password=iptInstall1", false, stream_context_create($arrContextOptions));
// $data2 = json_decode($konten2, true);

// // Backhaul Kacific
// $konten6 = @file_get_contents("https://202.55.175.235:8443/api/getsensordetails.json?id=25669&username=NOC%20TELEGLOBAL&password=iptInstall1", false, stream_context_create($arrContextOptions));
// $data6 = json_decode($konten6, true);

// $data = [
//    'sensordata' => [
//     'ipstar' => ['name' => $parsedData['sensordata']['name'], 'value' => $parsedData['sensordata']['lastvalue']]
//    //  'paket4' => ['name' => $data4['sensordata']['name'], 'value' => $data4['sensordata']['lastvalue']] ,
//    //  'paket5' => ['name' => $data5['sensordata']['name'], 'value' => $data5['sensordata']['lastvalue']] ,
//    ]
// ];
