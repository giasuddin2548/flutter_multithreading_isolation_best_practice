
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolation/model/ModelData.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
class MyBackgroundIsolation{


  var controller=BehaviorSubject<int>();

  void withoutIsolation(){

    for(int i=0 ; i<10000000;i++){
      controller.add(i)
      ;
    }
  }

  ///Basic Function
  Future<void> startOperation()async {
    /*
    Lexical Resource:
    Isolation Has three main parts
    1) ReceivePort which is perform as controller
    2) Isolate.spawn which is run the desired function and parameter is sent via list below example runTask is
       the main function and [receivePort.sendPort, 'Task-1', 10000000] is parameter and we can pass multiple parameter at a time.
    3) if further anything will happen  receivePort.close(); will close
    4) await receivePort.first it is works as a receiver ar response getter
    5) In the runTask method, it perform main task and being finished the task we also exit the isolation with sendPort and data Isolate.exit(sendPort,"$taskName Data=>$value" );
     */
    final ReceivePort receivePort=ReceivePort();
    try{
      await Isolate.spawn(runTask, [receivePort.sendPort, 'Task-1', 10000000]);

    }on Object{
      print("Isolate =>Failed");
      receivePort.close();
    }

    final response=await receivePort.first;
    print("Isolate =>Response :$response");
  }
  void runTask(List<dynamic> args) async{
    SendPort sendPort=args[0];
    String taskName=args[1];
    int time=args[2];

    ///Main operation will be here
    var value=0;
    for(int i=0 ; i<time;i++){
      value=i;
      controller.add(i);
    //  print("Data is being processed => $value");
    }

    Isolate.exit(sendPort,"$taskName Data=>$value" );
  }


  ///Fetch Data from Apis in Background
  Future<void> getDataOperation()async{
    final receiverPort=ReceivePort();
    await Isolate.spawn(fetch, [receiverPort.sendPort]);

    var receivedData=await receiverPort.first as ModelData;

    print('Data-Fetch-By-Server: ${receivedData.results?.length}');

  }
  void fetch(List<SendPort> args)async {
    var response=await fetchDataOnBackground();
    Isolate.exit(args[0],response);
  }
  Future<ModelData> fetchDataOnBackground()async{
    var url = Uri.parse("https://api.themoviedb.org/3/movie/now_playing?api_key=d81172160acd9daaf6e477f2b306e423&language=en-US");

    ModelData modelData=ModelData();

    try{
      var response = await http.get(url);
      if(response.statusCode==200){
        print(response.request?.url.toString());
        print(response.statusCode);
        var data=jsonDecode(response.body);
        modelData=ModelData.fromJson(data);
      }

    }catch (e){
      print(e);
    }

    return modelData;

  }

  ///Download Function

  Future<void> downloadFile()async{
    final receivePort=ReceivePort();
    try{

      await Isolate.spawn(isolationTask, [receivePort.sendPort, 'filename']);

    }on Object{
      receivePort.close();
    }

    var result=await receivePort.first;
    print('Download:-> $result');

  }

  void isolationTask(List<dynamic> args)async {
       var result= await download();
       Isolate.exit(args[0], result);

  }

  Future<dynamic> download() async{
    var dir = await getApplicationDocumentsDirectory();
    var url="https://rr2---sn-9gv7zn7e.googlevideo.com/videoplayback?expire=1690118344&ei=aNS8ZPOYFZCM2_gPupG-4Aw&ip=177.249.160.7&id=o-AIhltJ4yodrmZi84vPVzl6wRbRuwZiE5F0Z0VcF9xVr_&itag=22&source=youtube&requiressl=yes&mh=aa&mm=31%2C29&mn=sn-9gv7zn7e%2Csn-cxnuxa-hxml&ms=au%2Crdu&mv=m&mvi=2&pl=23&initcwndbps=1605000&bui=AYlvQAtWFVipVeGSwQDfSiS9mBq99ooKSPQRPVjH-IXXS2s6YuzT-i7Scp0-3dsGlaMsi1vPpWoLqm2Gy5U-OGrT4up2f_1r&spc=Ul2SqwGWp3xhP1LhD-4sTfI76La3jKWoyLoh2PJvFA&vprv=1&svpuc=1&mime=video%2Fmp4&ns=lMNOhNPpjihOK-bWFGuO5I0O&cnr=14&ratebypass=yes&dur=2119.308&lmt=1682639888719672&mt=1690096393&fvip=3&fexp=24007246%2C51000014&beids=24350017&c=WEB&txp=5311224&n=d3GXPqY7rs3Qlw&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cbui%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cns%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRgIhAIcp11OkGgRbgnsUUvZuS5HQ-ma-5c53yC_Z_-QZKAD-AiEA55nB1ioj8wBvSk8bZYyW35JdW8AUt6PJ1we1qNUqfkM%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRgIhAPGhW1l6kV0Uuiekyay4syU2N8vMaQYcm_vgTpmOF8pGAiEAwIrlh1auFAo2csIUoF_Du1F3LCs0iOLtO3vEzVz3n9E%3D&title=BLoC%20in%20Flutter%20%7C%20Ep.%201%20-%20BLoC%2C%20Events%20and%20States%20%7C%20BLoC%20Explanation%20and%20Usage%20%7C%20Hindi";

    var status='';

    try{
      await Dio().download(url, dir.path, onReceiveProgress:  (received, total) {
        if (total != -1) {
          print("${(received / total * 100).toStringAsFixed(0)}%");
          //you can build progressbar feature too
        }
      });
      // if(response.statusCode==200){
      //   print(response.requestOptions.uri);
      //   print(response.statusCode);
      //   status="Success";
      // }

    }catch (e){
      print(e);
      status="Failed";
    }

    return status;

  }
  }

