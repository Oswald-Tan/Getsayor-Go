import 'package:flutter/material.dart';
import 'package:getsayor/data/services/afiliasi_bonus_service.dart';
import 'package:getsayor/data/model/afiliasi_bonus_model.dart';

class PendingBonusesPage extends StatefulWidget {
  const PendingBonusesPage({super.key});

  @override
  State<PendingBonusesPage> createState() => _PendingBonusesPageState();
}

class _PendingBonusesPageState extends State<PendingBonusesPage> {
  final AfiliasiBonusService _bonusService = AfiliasiBonusService();

  // Fungsi untuk klaim bonus
  Future<void> _claimBonus(int bonusId) async {
    try {
      await _bonusService.claimBonus(context, bonusId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bonus berhasil diklaim!')),
        );
      }
      setState(() {}); // Refresh data setelah klaim
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal klaim bonus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Bonuses'),
      ),
      body: FutureBuilder<List<AfiliasiBonus>>(
        future: _bonusService.getPendingBonuses(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada bonus pending.'),
            );
          }

          final List<AfiliasiBonus> bonuses = snapshot.data!;
          return ListView.builder(
            itemCount: bonuses.length,
            itemBuilder: (context, index) {
              final bonus = bonuses[index];
              return ListTile(
                title: Text(
                  'Bonus ID: ${bonus.id}',
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Amount: ${bonus.bonusAmount}\nExpiry: ${bonus.expiryDate}\nStatus: ${bonus.status}',
                ),
                trailing: ElevatedButton(
                  onPressed: bonus.status == 'pending'
                      ? () => _claimBonus(bonus.id)
                      : null, // Disable tombol jika status bukan pending
                  child: const Text('Claim'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
