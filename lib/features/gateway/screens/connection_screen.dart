import 'package:flutter/material.dart';

import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/feedback/inline_error.dart';
import '../../../core/widgets/buttons/loading_button.dart';
import '../../../l10n/app_localizations.dart';

import '../localization/gateway_failure_localization.dart';
import '../models/connection_failure.dart';
import '../models/gateway_info.dart';
import '../services/gateway_health_service.dart';
import '../validators/gateway_validators.dart';
import '../widgets/delete_gateway_dialog.dart';
import '../widgets/gateway_health_status_widget.dart';
import '../widgets/saved_gateway_tile.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({
    super.key,
    required this.onConnect,
    this.onConnectSaved,
    this.onDeleteSaved,
    this.onUseSimulated,
    this.savedGateways = const [],
    this.initialHost = '',
    this.initialPort = '',
  });

  final Future<void> Function(String host, String port) onConnect;
  final Future<void> Function(GatewayInfo gateway)? onConnectSaved;
  final Future<void> Function(GatewayInfo gateway)? onDeleteSaved;
  final Future<void> Function()? onUseSimulated;
  final List<GatewayInfo> savedGateways;
  final String initialHost;
  final String initialPort;

  @override
  State<ConnectionScreen> createState() =>
      _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _hostController;
  late final TextEditingController _portController;

  bool _isConnecting = false;
  bool _isConnected = false;

  ConnectionFailure? _failure;

  AutovalidateMode _autovalidateMode =
      AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();

    _hostController =
    TextEditingController(text: widget.initialHost)
      ..addListener(_clearConnectionError);

    _portController =
    TextEditingController(text: widget.initialPort)
      ..addListener(_clearConnectionError);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _clearConnectionError() {
    if (_failure != null || _isConnected) {
      setState(() {
        _failure = null;
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
      _failure = null;
      _isConnected = false;
    });

    ConnectionFailure? failure;

    try {
      await action();
    } catch (error) {
      debugPrint('Connection failed: $error');
      failure = ConnectionFailure.fromError(error);
    }

    if (!mounted) return;

    setState(() {
      _isConnecting = false;
      _failure = failure;
      _isConnected = showSuccess && failure == null;
    });
  }

  void _submit() {
    if (_isConnecting) return;

    if (!_formKey.currentState!.validate()) {
      setState(
            () => _autovalidateMode =
            AutovalidateMode.onUserInteraction,
      );
      return;
    }

    _runConnecting(
          () => widget.onConnect(
        _hostController.text.trim(),
        _portController.text.trim(),
      ),
    );
  }

  void _connectToSaved(
      GatewayInfo gateway,
      Future<void> Function(GatewayInfo gateway) onConnectSaved,
      ) {
    if (_isConnecting) return;

    _hostController.text = gateway.host;
    _portController.text = gateway.port.toString();

    _runConnecting(() => onConnectSaved(gateway));
  }

  Future<void> _deleteSaved(
      GatewayInfo gateway,
      Future<void> Function(GatewayInfo gateway) onDeleteSaved,
      ) async {
    if (_isConnecting) return;

    final confirmed =
    await confirmDeleteGateway(context, gateway);

    if (!confirmed || !mounted) return;

    await onDeleteSaved(gateway);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final textTheme = Theme.of(context).textTheme;
    final onUseSimulated = widget.onUseSimulated;
    final onConnectSaved = widget.onConnectSaved;
    final onDeleteSaved = widget.onDeleteSaved;

    final errorMessage = _failure?.localizedMessage(l10n);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          children: [
            Text(
              l10n.connectToGateway,
              style: textTheme.titleLarge,
            ),

            const SizedBox(height: 24),

            ActionCard(
              icon: Icons.science_outlined,
              title: l10n.simulatedData,
              subtitle: l10n.simulatedDataSubtitle,
              onTap: (onUseSimulated == null || _isConnecting)
                  ? null
                  : () => _runConnecting(
                onUseSimulated,
                showSuccess: false,
              ),
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
                      label: l10n.gatewayAddress,
                      hint: '192.168.0.100',
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      enabled: !_isConnecting,
                      validator: (value) =>
                          validateGatewayHost(
                            value,
                            l10n: l10n,
                          ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    width: 112,
                    child: AppTextField(
                      controller: _portController,
                      label: l10n.port,
                      hint: l10n.optional,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enabled: !_isConnecting,
                      validator: (value) =>
                          validateGatewayPort(
                            value,
                            l10n: l10n,
                          ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            LoadingButton(
              label: errorMessage == null
                  ? l10n.connect
                  : l10n.tryAgain,
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

              Text(
                l10n.savedGateways,
                style: textTheme.titleSmall,
              ),

              const SizedBox(height: 8),

              for (final gateway in widget.savedGateways) ...[
                SavedGatewayTile(
                  gateway: gateway,
                  onConnect:
                  (onConnectSaved == null || _isConnecting)
                      ? null
                      : () => _connectToSaved(
                    gateway,
                    onConnectSaved,
                  ),
                  onDelete:
                  (onDeleteSaved == null || _isConnecting)
                      ? null
                      : () => _deleteSaved(
                    gateway,
                    onDeleteSaved,
                  ),
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