
import 'package:flutter/material.dart';

import 'myBackgorundIsolation.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {



  MyBackgroundIsolation myBackgroundIsolation=MyBackgroundIsolation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Flutter Isolation"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder(
              stream: myBackgroundIsolation.controller.stream,
              builder: (_, snap){
                if(snap.hasData){
                  return Text("${snap.data??''}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),);
                }else{
                  return const Text("0", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),);
                }
              },
          ),
          const SizedBox(height: 60,),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 40,),
          Center(child: TextButton(onPressed: myBackgroundIsolation.withoutIsolation, child: const Text('Without Isolation'))),
          const SizedBox(height: 10,),
          Center(child: TextButton(onPressed: myBackgroundIsolation.startOperation, child: const Text('With Isolation'))),
          Center(child: TextButton(onPressed: myBackgroundIsolation.fetchDataOnBackground, child: const Text('Fetch Data from Server'))),
          Center(child: TextButton(onPressed: myBackgroundIsolation.downloadFile, child: const Text('Download file'))),
        ],
      ),
    );
  }
}
