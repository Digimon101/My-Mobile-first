import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/model/request/customer_login_post_req.dart';
import 'package:my_first_app/model/response/customer_login_post_res.dart';

import 'package:my_first_app/pages/register.dart';
import 'package:my_first_app/pages/showTrip.dart';
import 'package:my_first_app/config/internal_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String text = '';
  int number = 0;
  String phoneNo = '';
  var phoneNoCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(child: Image.asset('assets/images/logo.png')),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("หมายเลขโทรศัพท์"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: phoneNoCtl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("รหัสผ่าน"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: passwordCtl,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: register,
                      // ไปหน้าลงทะเบียน
                      child: Text("ลงทะเบียน"),
                    ),
                    ElevatedButton(
                      onPressed: login,
                      // เข้าสู่ระบบ
                      child: Text("เข้าสู่ระบบ"),
                    ),
                  ],
                ),
                Text(text, style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    CustomerLoginPostRequest req = CustomerLoginPostRequest(
      phone: phoneNoCtl.text,
      password: passwordCtl.text,
    );
    http
        .post(
          Uri.parse("$API_ENDPOINT/customers/login"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: customerLoginPostRequestToJson(req),
        )
        .then((value) {
          log(value.body);
          CustomerLoginPostResponse customerLoginPostResponse =
              customerLoginPostResponseFromJson(value.body);
          if (customerLoginPostResponse.customer != null) {
            log(customerLoginPostResponse.customer.fullname);
            log(customerLoginPostResponse.customer.email);

            // ถ้า login ถูกต้อง ไปหน้า ShowTrip
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ShowTripPage(cid: customerLoginPostResponse.customer.idx),
              ),
            );
          } else {
            // ถ้า login ผิดพลาด
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed. Please check your credentials."),
              ),
            );
          }
        })
        .catchError((error) {
          log('Error $error');
        });
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }
}
