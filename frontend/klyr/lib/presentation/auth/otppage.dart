import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klyr/presentation/auth/bloc/authbloc.dart';
import 'package:klyr/presentation/auth/bloc/authevent.dart';
import 'package:klyr/presentation/auth/bloc/authstate.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
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
        } else if (!state.isLoading && state.message == "otp-verified") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP verified successfully")),
          );
        } else if (!state.isLoading &&
            state.message == "otp-sent" &&
            state.email == widget.email) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("OTP resent")));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.orange,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: height * 0.025),
                        Text(
                          "Enter OTP",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: height * 0.04,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We've sent a verification code to",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: height * 0.019,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: height * 0.019,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.035),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.lock_outline,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Verification code",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 10,
                                    ),
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "000000",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                BlocBuilder<Authbloc, Authstate>(
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: state.isLoading
                                            ? null
                                            : () {
                                                final otp =
                                                    _otpController.text.trim();
                                                context.read<Authbloc>().add(
                                                  VerifyOTPEvent(
                                                    email: widget.email,
                                                    otp: otp,
                                                  ),
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: state.isLoading
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
                                                "Verify",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.025),
                          TextButton(
                            onPressed: () {
                              context.read<Authbloc>().add(
                                GetOTPEvent(email: widget.email),
                              );
                            },
                            child: const Text(
                              "Resend code",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
