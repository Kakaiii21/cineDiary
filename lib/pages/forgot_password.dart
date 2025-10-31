import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool iChecked = false;
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(15, 29, 56, 1),

      //------------------------------LOGO----------------------------------------------
      body: Stack(
        children: [
          Positioned(
            top: 80,
            left: -5,
            right: 0,

            child: Center(
              child: Image.asset("assets/images/logo.png", height: 300),
            ),
          ),

          //------------------------------------RECTANGLE WHITE--------------------
          Align(
            alignment: Alignment.bottomCenter,

            child: Container(
              height: 450,
              width: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),

              child: Column(
                children: [
                  const SizedBox(height: 30),

                  //---------------------------OBLONG GREY-------------------------------
                  Container(
                    width: 350,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(232, 229, 229, 1), //lightgrey
                      borderRadius: BorderRadius.circular(30),
                    ),

                    //-----------------------FORGOT PASSWORD TEXT--------------------------
                    child: Center(
                      child: Text(
                        "FORGOT PASSWORD",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(15, 29, 56, 1),
                        ),
                      ),
                    ),
                  ),

                  //---------------------------NEXT LINE----------------------------
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 40,
                      right: 40,
                    ),
                    child: Column(
                      children: [
                        //-------------------------EMAIL----------------------------
                        TextField(
                          controller: _emailController,
                          obscureText: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: Color.fromRGBO(15, 29, 56, 1),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(15, 29, 56, 0.5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(15, 29, 56, 1),
                                width: 2.0,
                              ),
                            ),
                            hintText: "Enter email",
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(15, 29, 56, 0.5),
                              fontSize: 16,
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Color.fromRGBO(15, 29, 56, 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        //---------------------------NEXT LINE----------------------------
                        SizedBox(height: 10),

                        //-------------------------CODE---------------------------
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.chat,
                                    color: Color.fromRGBO(15, 29, 56, 1),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(15, 29, 56, 0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(15, 29, 56, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  hintText: "Enter Code",
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(15, 29, 56, 0.5),
                                    fontSize: 16,
                                  ),
                                ),
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Color.fromRGBO(15, 29, 56, 1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ), // spacing between textfield and button
                            //--------------------SEND CODE BUTTON---------------------
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(15, 29, 56, 1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Send Code",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        //---------------------------NEXT LINE----------------------------
                        SizedBox(height: 5),

                        //---------------------------NEW PASSWORD----------------------------
                        TextField(
                          obscureText: true,
                          obscuringCharacter: "●",
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color.fromRGBO(15, 29, 56, 1),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(15, 29, 56, 0.5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(15, 29, 56, 1),
                                width: 2.0,
                              ),
                            ),
                            hintText: "New password",
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(15, 29, 56, 0.5),
                              fontSize: 16,
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Color.fromRGBO(15, 29, 56, 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        //---------------------------NEXT LINE----------------------------
                        SizedBox(height: 5),

                        //---------------------------CONFIRM PASSWORD----------------------------
                        TextField(
                          obscureText: true,
                          obscuringCharacter: "●",
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color.fromRGBO(15, 29, 56, 1),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(15, 29, 56, 0.5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(15, 29, 56, 1),
                                width: 2.0,
                              ),
                            ),
                            hintText: "Confirm password",
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(15, 29, 56, 0.5),
                              fontSize: 16,
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Color.fromRGBO(15, 29, 56, 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        //---------------------------NEXT LINE----------------------------
                        SizedBox(height: 5),

                        //------------------------------REMEMBER ME-----------------
                        Row(
                          children: [
                            Checkbox(
                              value: iChecked,
                              onChanged: (value) {
                                iChecked = !iChecked;
                                setState(() {});
                              },
                            ),
                            Text(
                              "Remember Me",
                              style: TextStyle(
                                color: Color.fromRGBO(15, 29, 56, 0.5),
                              ),
                            ),
                          ],
                        ),

                        //---------------------------NEXT LINE----------------------------
                        SizedBox(height: 10),

                        //--------------------SEND CODE BUTTON---------------------
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(15, 29, 56, 1),
                            padding: EdgeInsets.symmetric(
                              horizontal: 110,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "LOG IN",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
