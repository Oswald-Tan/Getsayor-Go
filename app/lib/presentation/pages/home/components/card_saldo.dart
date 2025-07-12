import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';

class CardSaldo extends StatefulWidget {
  const CardSaldo({super.key});

  @override
  CardSaldoState createState() => CardSaldoState();
}

class CardSaldoState extends State<CardSaldo> {
  bool isSaldoVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final saldo = userProvider.points ?? 0;

        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: Colors.black,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Image.asset(
                      width: 18,
                      'assets/images/poin.png',
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          saldo.toString(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
