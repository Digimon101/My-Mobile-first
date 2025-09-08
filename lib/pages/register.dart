import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/model/request/customer_register_post_req.dart';
import 'package:my_first_app/model/response/customer_register_post_res.dart';
import 'package:my_first_app/pages/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullnameCtl = TextEditingController();
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmPasswordCtl = TextEditingController();

  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนสมาชิกใหม่')),
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ชื่อ-นามสกุล', style: TextStyle(fontSize: 15)),
                      TextField(
                        controller: fullnameCtl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          errorText: fullnameCtl.text.trim().isEmpty
                              ? 'กรุณากรอกชื่อ'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('หมายเลขโทรศัพท์', style: TextStyle(fontSize: 15)),
                      TextField(
                        controller: phoneNoCtl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          errorText: phoneNoCtl.text.trim().isEmpty
                              ? 'กรุณากรอกหมายเลขโทรศัพท์'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('อีเมล์', style: TextStyle(fontSize: 15)),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                        controller: emailCtl,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('รหัสผ่าน', style: TextStyle(fontSize: 15)),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                        controller: passwordCtl,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยืนยันรหัสผ่าน', style: TextStyle(fontSize: 15)),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                        controller: confirmPasswordCtl,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                FilledButton(
                  onPressed: register,
                  child: const Text('สมัครสมาชิก'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 40),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text('หากมีบัญชีอยู่แล้ว?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text('เข้าสู่ระบบ'),
                  ),
                ],
              ),
            ),
            Text(text, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  void register() {
    if (passwordCtl.text == confirmPasswordCtl.text) {
      CustomerRegisterPostRequest req = CustomerRegisterPostRequest(
        fullname: fullnameCtl.text,
        phone: phoneNoCtl.text,
        email: emailCtl.text,
        image: "",
        password: passwordCtl.text,
      );

      http
          .post(
            Uri.parse("http://192.168.1.138:3000/customers"),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: customerRegisterPostRequestToJson(req),
          )
          .then((value) {
            log(value.body);
            CustommerRegisterPostRes customerRegisterPostResponse =
                custommerRegisterPostResFromJson(value.body);
            log(customerRegisterPostResponse.message);
          })
          .catchError((error) {
            log('Error $error');
          });

      setState(() {
        text = 'Register Successful';
      });
    } else {
      setState(() {
        text = 'Can not register';
      });
    }
  }
}
