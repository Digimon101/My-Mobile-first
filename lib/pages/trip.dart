import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_first_app/config/internal_config.dart';
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/config/internal_config.dart';
import 'package:my_first_app/model/response/trip_idx_get_res.dart';
import 'package:http/http.dart' as http;

class TripPage extends StatefulWidget {
  int idx = 0;
  TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  String url = 'http://10.160.10.196:3000';
  late TripIdxGetResponse tripIdxGetResponse;
  late Future<void> loadData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดทริป')),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripIdxGetResponse.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 2,
                    ),
                  ),
                  Text(
                    tripIdxGetResponse.country,
                    style: TextStyle(fontSize: 15, height: 2),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Image.network(
                      tripIdxGetResponse.coverimage ?? '',
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('โหลดรูปไม่ได้: $error');
                        return SizedBox(
                          width: 500,
                          height: 200,
                          child: Center(
                            child: Text(
                              'โหลดภาพไม่ได้',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ราคา ${tripIdxGetResponse.price} บาท'),
                        Text('โซน${tripIdxGetResponse.destinationZone}'),
                      ],
                    ),
                  ),
                  Text(tripIdxGetResponse.detail),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(150, 40),
                          ),
                          child: const Text('จองเลย!!'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadDataAsync() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips/${widget.idx}'));
    log(res.body);

    setState(() {
      tripIdxGetResponse = tripIdxGetResponseFromJson(res.body);
    });
  }
}
