import 'package:flutter/material.dart';

class DeviceConfigBottomSheet extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portController;
  final TextEditingController passwordController;
  final bool isConnecting;
  final VoidCallback onTestConnection;
  final VoidCallback onSave;

  const DeviceConfigBottomSheet({
    super.key,
    required this.ipController,
    required this.portController,
    required this.passwordController,
    required this.isConnecting,
    required this.onTestConnection,
    required this.onSave,
  });

  static void show({
    required BuildContext context,
    required TextEditingController ipController,
    required TextEditingController portController,
    required TextEditingController passwordController,
    required bool isConnecting,
    required VoidCallback onTestConnection,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DeviceConfigBottomSheet(
        ipController: ipController,
        portController: portController,
        passwordController: passwordController,
        isConnecting: isConnecting,
        onTestConnection: onTestConnection,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Biometric Device Setup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Configure network parameters for biometric terminal communication (ZKTeco / eSSL).',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: ipController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Device IP Address',
                hintText: '192.168.1.201',
                prefixIcon: Icon(Icons.router_outlined),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '4370',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Comm Key / Pin',
                      hintText: '0',
                      prefixIcon: Icon(Icons.key_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isConnecting
                    ? null
                    : () {
                        Navigator.pop(context);
                        onTestConnection();
                      },
                icon: isConnecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find_rounded),
                label: const Text('Test Connection'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5D9F),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onSave();
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
