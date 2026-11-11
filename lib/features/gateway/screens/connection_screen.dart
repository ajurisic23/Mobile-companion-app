import 'package:flutter/material.dart';
import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/inline_error.dart';
import '../../../core/widgets/loading_button.dart';
import '../models/connection_failure.dart';
import '../models/gateway_info.dart';
import '../services/gateway_health_service.dart';
import '../validators/gateway_validators.dart';
import '../widgets/gateway_health_status_widget.dart';
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
  bool _isConnected = false;
  String? _errorMessage;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.initialHost)
      ..addListener(_clearConnectionError);
    _portController = TextEditingController(text: widget.initialPort)
      ..addListener(_clearConnectionError);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _clearConnectionError() {
    if (_errorMessage != null || _isConnected) {
      setState(() {
        _errorMessage = null;
        _isConnected = false;
      });
    }
  }

  Future<void> _runConnecting(
      Future<void> Function() action, {
        bool showSuccess = true,
      }) async {
    if (_isConnecting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _isConnected = false;
    });

    String? errorMessage;
    try {
      await action();
    } catch (error) {
      debugPrint('Connection failed: $error');
      errorMessage = ConnectionFailure.fromError(error).message;
    }

    if (!mounted) return;
    setState(() {
      _isConnecting = false;
      _errorMessage = errorMessage;
      _isConnected = showSuccess && errorMessage == null;
    });
  }

  void _submit() {
    if (_isConnecting) return;

    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

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
    final errorMessage = _errorMessage;

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
                  : () => _runConnecting(onUseSimulated, showSuccess: false),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
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
                      validator: validateGatewayHost,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 112,
                    child: AppTextField(
                      controller: _portController,
                      label: 'Port',
                      hint: 'optional',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enabled: !_isConnecting,
                      validator: validateGatewayPort,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LoadingButton(
              label: errorMessage == null ? 'Connect' : 'Try again',
              isLoading: _isConnecting,
              onPressed: _submit,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              InlineError(message: errorMessage),
            ],
            if (_isConnected) ...[
              const SizedBox(height: 16),
              const GatewayHealthStatusWidget(
                status: GatewayHealthStatus.available,
              ),
            ],
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