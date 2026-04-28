import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klyr/presentation/auth/bloc/authbloc.dart';
import 'package:klyr/presentation/auth/bloc/authevent.dart';
import 'package:klyr/presentation/auth/bloc/authstate.dart';

class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<Authbloc, Authstate>(
      listener: (context, state) {
        if (state.isError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (!state.isLoading &&
            state.message == "otp-sent" &&
            state.email != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("OTP sent to ${state.email}")));
          context.pushNamed("otppage", extra: state.email);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome!",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: height * 0.04,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        //SizedBox(height: 5,),
                        Text(
                          "Let's get you logged in",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: height * 0.25,
                          width: width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.5),
                                blurRadius: 8,
                                //spreadRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Enter your email"),
                                  ],
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "youremail@example.com",
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Spacer(),
                                BlocBuilder<Authbloc, Authstate>(
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: double.infinity, // full width
                                      height: height * 0.06,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            state.isLoading
                                                ? null
                                                : () {
                                                  final email =
                                                      _emailController.text
                                                          .trim();
                                                  context.read<Authbloc>().add(
                                                    GetOTPEvent(email: email),
                                                  );
                                                },
                                        child:
                                            state.isLoading
                                                ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                                : const Text(
                                                  "Continue",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      ),
                                    );
                                  },
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.1,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: height * 0.03,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Container(
                          height: height * 0.05,
                          width: width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.5),
                                blurRadius: 8,
                                //spreadRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.read<Authbloc>().add(GoogleAuthEvent());
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.asset(
                                      "lib/assets/images/google_logo.png",
                                    ),
                                    Text(
                                      "Continue with Google",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ), //Google auth container
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
