import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository.dart';
import '../models.dart' as m;

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({Key? key, required this.onDone}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Cash');
  final _balanceCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome — Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Create initial account', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Account name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter account name' : null,
              ),
              TextFormField(
                controller: _balanceCtrl,
                decoration: const InputDecoration(labelText: 'Initial balance'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Enter balance' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final repo = Provider.of<Repository>(context, listen: false);
                    
                    // Add initial account
                    final a = m.Account(
                      name: _nameCtrl.text,
                      balance: double.tryParse(_balanceCtrl.text) ?? 0.0,
                    );
                    await repo.addAccount(a);

                    // Add predefined categories
                    for (final catName in m.PredefinedData.expenseCategories) {
                      await repo.addCategory(m.Category(name: catName));
                    }
                    for (final catName in m.PredefinedData.incomeCategories) {
                      await repo.addCategory(m.Category(name: catName));
                    }

                    widget.onDone();
                  }
                },
                child: const Text('Finish Setup'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
