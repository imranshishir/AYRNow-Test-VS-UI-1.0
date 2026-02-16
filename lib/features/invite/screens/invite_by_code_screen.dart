import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';
import 'package:ayrnow/features/invite/screens/invite_accept_screen.dart';
import 'package:ayrnow/core/services/mock_service.dart';
import 'package:ayrnow/ui/shared/widgets/primary_button.dart';

class InviteByCodeScreen extends ConsumerStatefulWidget {
  const InviteByCodeScreen({super.key});

  @override
  ConsumerState<InviteByCodeScreen> createState() => _InviteByCodeScreenState();
}

class _InviteByCodeScreenState extends ConsumerState<InviteByCodeScreen> {
  final _codeController = TextEditingController();
  final _focus = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _error = 'Enter your invite code';
        _loading = false;
      });
      return;
    }
    if (!MockService.isValidInviteCodeFormat(code)) {
      setState(() {
        _error = 'Code must be at least 6 characters (letters, numbers, or hyphens)';
        _loading = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final store = ref.read(inviteStoreProvider.notifier);
    final invite = store.findByCode(code.toUpperCase());
    setState(() => _loading = false);
    if (!mounted) return;
    if (invite != null && invite.isPending && !invite.isExpiredByTime) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InviteAcceptScreen(code: invite.code),
        ),
      );
    } else {
      setState(() {
        _error = 'Invite not found or expired. Check the code and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Enter invite code')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Have an invite code? Enter it below to join a property.',
            style: t.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeController,
            focusNode: _focus,
            decoration: InputDecoration(
              labelText: 'Invite code',
              hintText: 'e.g. ABC123-XY',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continue',
            isLoading: _loading,
            onPressed: _submit,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to dashboard'),
          ),
        ],
      ),
    );
  }
}
