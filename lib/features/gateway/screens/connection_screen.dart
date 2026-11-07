import 'package:flutter/material.dart';

import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../models/gateway_info.dart';
import '../widgets/saved_gateway_tile.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({
    super.key,
    required this.onConnect,
    this.onConnectSaved,
    this.onUseSimulated,
    this.savedGateways = const [],
    this.initialHost = '',
    this.initialPort = '',
  });

  final Future<void> Function(String host, String port) onConnect;
  final Future<void> Function(GatewayInfo gateway)? onConnectSaved;
  final Future<void> Function()? onUseSimulated;
  final List<GatewayInfo> savedGateways;
  final String initialHost;
  final String initialPort;

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.initialHost);
    _portController = TextEditingController(text: widget.initialPort);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _runConnecting(Future<void> Function() action) async {
    if (_isConnecting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isConnecting = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _submit() {
    // U idućem tasku ovdje validatori odlučuju ide li se dalje.
    if (!_formKey.currentState!.validate()) return;
    _runConnecting(
          () => widget.onConnect(
        _hostController.text.trim(),
        _portController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onUseSimulated = widget.onUseSimulated;
    final onConnectSaved = widget.onConnectSaved;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Connect to a CAN gateway', style: textTheme.titleLarge),
            const SizedBox(height: 24),
            ActionCard(
              icon: Icons.science_outlined,
              title: 'Simulated data',
              subtitle: 'continue without connecting to a real device',
              onTap: (onUseSimulated == null || _isConnecting)
                  ? null
                  : () => _runConnecting(onUseSimulated),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _hostController,
                      label: 'Gateway address',
                      hint: '192.168.0.100',
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      enabled: !_isConnecting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    child: AppTextField(
                      controller: _portController,
                      label: 'Port',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enabled: !_isConnecting,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LoadingButton(
              label: 'Connect',
              isLoading: _isConnecting,
              onPressed: _submit,
            ),
            if (widget.savedGateways.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Saved gateways', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final gateway in widget.savedGateways) ...[
                SavedGatewayTile(
                  gateway: gateway,
                  onConnect: (onConnectSaved == null || _isConnecting)
                      ? null
                      : () => _runConnecting(() => onConnectSaved(gateway)),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}