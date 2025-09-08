import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/config.dart';
import 'dart:developer';

import 'package:my_first_app/model/response/trip_get_res.dart';
import 'package:my_first_app/pages/login.dart';
import 'package:my_first_app/pages/profile.dart';
import 'package:my_first_app/pages/trip.dart';

class ShowTripPage extends StatefulWidget {
  int cid = 0;
  ShowTripPage({super.key, required this.cid});

  @override
  State<ShowTripPage> createState() => _ShowTripPageState();
}

class _ShowTripPageState extends State<ShowTripPage> {
  String url = 'http://192.168.1.138:3000';
  List<TripGetResponse> tripGetResponses = [];
  bool isLoading = true;

  String selectedRegion = 'ทั้งหมด'; // ✅ เก็บ state ของปุ่ม filter ที่เลือก

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  initializeData() async {
    try {
      var config = await Configuration.getConfig();
      url = config['apiEndpoint'];
      await getTrips();
    } catch (e) {
      log('Error initializing: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('รายการทริป'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(idx: widget.cid),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('ข้อมูลส่วนตัว'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัวข้อปลายทาง
            const Text(
              'ปลายทาง',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // ปุ่ม filter แต่ละประเทศ
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterButton('ทั้งหมด'),
                  _buildFilterButton('เอเชีย'),
                  _buildFilterButton('ยุโรป'),
                  _buildFilterButton('อาเซียน'),
                  _buildFilterButton('อเมริกา'),
                  _buildFilterButton('ไทย'),
                  _buildFilterButton('จีน'),
                  _buildFilterButton('ลาว'),
                  _buildFilterButton('กัมพูชา'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // รายการทริป
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tripGetResponses.isEmpty
                  ? const Center(child: Text('ไม่มีข้อมูลทริป'))
                  : ListView.builder(
                      itemCount: tripGetResponses.length,
                      itemBuilder: (context, index) {
                        return _buildTripCard(tripGetResponses[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้างปุ่ม filter
  Widget _buildFilterButton(String text) {
    final bool isSelected = selectedRegion == text;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedRegion = text;
          });
          getTrips(region: text);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
          elevation: 0,
          side: BorderSide(color: Colors.deepPurple.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // สร้าง Card สำหรับแต่ละทริป
  Widget _buildTripCard(TripGetResponse trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                child: trip.coverimage != null && trip.coverimage!.isNotEmpty
                    ? Image.network(
                        trip.coverimage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // ข้อมูลทริป
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อทริป
                  Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ประเทศและระยะเวลา
                  Row(
                    children: [
                      if (trip.country != null) ...[
                        Text(
                          'ประเทศ${trip.country}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (trip.duration != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'ระยะเวลา ${trip.duration} วัน',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ราคา
                  if (trip.price != null)
                    Text(
                      'ราคา ${trip.price?.toStringAsFixed(0)} บาท',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ปุ่มรายละเอียดเพิ่มเติม
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripPage(idx: trip.idx),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'รายละเอียดเพิ่มเติม',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // โหลด Trips จาก API
  getTrips({String? region}) async {
    setState(() {
      isLoading = true;
    });

    try {
      var uri = Uri.parse('$url/trips');
      if (region != null && region != 'ทั้งหมด') {
        uri = Uri.parse('$url/trips?region=$region');
      }

      var res = await http.get(uri);
      log('Response: ${res.body}');

      if (res.statusCode == 200) {
        setState(() {
          tripGetResponses = tripGetResponseFromJson(res.body);
          isLoading = false;
        });
        log('Loaded ${tripGetResponses.length} trips');
      } else {
        throw Exception('Failed to load trips: ${res.statusCode}');
      }
    } catch (e) {
      log('Error getting trips: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}
