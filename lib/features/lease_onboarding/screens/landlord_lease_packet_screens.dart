import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/state/providers.dart';
import '../../invite/invite_api.dart';
import '../lease_onboarding_models.dart';
import '../lease_onboarding_api.dart';

final _currencyFormatter = NumberFormat.simpleCurrency(decimalDigits: 0);

class LeasePacketCreateScreen extends ConsumerStatefulWidget {
  final String unitId;
  final String? unitLabel;

  const LeasePacketCreateScreen({
    super.key,
    required this.unitId,
    this.unitLabel,
  });

  @override
  ConsumerState<LeasePacketCreateScreen> createState() =>
      _LeasePacketCreateScreenState();
}

class _LeasePacketCreateScreenState
    extends ConsumerState<LeasePacketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantNameCtrl = TextEditingController();
  final _tenantContactCtrl = TextEditingController();
  DateTime? _leaseStartDate;
  final _monthlyRentCtrl = TextEditingController();
  final _securityDepositCtrl = TextEditingController();
  int _leaseTermMonths = 12;
  String _utilitiesResponsibility = 'tenant';
  bool _petsAllowed = false;
  final _specialNotesCtrl = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _tenantNameCtrl.dispose();
    _tenantContactCtrl.dispose();
    _monthlyRentCtrl.dispose();
    _securityDepositCtrl.dispose();
    _specialNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create lease packet'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.unitLabel != null && widget.unitLabel!.isNotEmpty)
                Text(
                  widget.unitLabel!,
                  style: theme.textTheme.titleMedium,
                ),
              if (widget.unitLabel != null && widget.unitLabel!.isNotEmpty)
                const SizedBox(height: 12),
              Text(
                'Start with just the essentials. AYRNOW will suggest the rest of the lease for you to review.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tenantNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tenant full name *',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter tenant name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tenantContactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tenant email or phone *',
                  helperText: 'Used for the invite link to this lease packet.',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter email or phone' : null,
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'Lease start date *',
                value: _leaseStartDate,
                onChanged: (d) => setState(() => _leaseStartDate = d),
              ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _monthlyRentCtrl,
                label: 'Monthly rent *',
                prefixText: _currencyFormatter.currencySymbol,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter monthly rent' : null,
              ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _securityDepositCtrl,
                label: 'Security deposit *',
                prefixText: _currencyFormatter.currencySymbol,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter security deposit'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _leaseTermMonths,
                decoration: const InputDecoration(
                  labelText: 'Lease term (months) *',
                ),
                items: const [6, 12, 18, 24]
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text('$m months'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _leaseTermMonths = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _utilitiesResponsibility,
                decoration: const InputDecoration(
                  labelText: 'Who pays utilities? *',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'tenant',
                    child: Text('Tenant pays utilities'),
                  ),
                  DropdownMenuItem(
                    value: 'landlord',
                    child: Text('Landlord pays utilities'),
                  ),
                  DropdownMenuItem(
                    value: 'split',
                    child: Text('Split (see notes)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _utilitiesResponsibility = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Pets allowed'),
                subtitle: const Text('You can add details in notes.'),
                value: _petsAllowed,
                onChanged: (v) => setState(() => _petsAllowed = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialNotesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Special notes (optional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
                label: const Text('Continue to suggestions'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || _leaseStartDate == null) {
      setState(() {
        _error ??= _leaseStartDate == null
            ? 'Please pick a lease start date.'
            : null;
      });
      return;
    }
    double? rent = double.tryParse(_monthlyRentCtrl.text.replaceAll(',', ''));
    double? deposit =
        double.tryParse(_securityDepositCtrl.text.replaceAll(',', ''));
    if (rent == null || deposit == null) {
      setState(() {
        _error = 'Enter valid amounts for rent and deposit.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final packet = await api.createPacket(
        unitId: widget.unitId,
        tenantName: _tenantNameCtrl.text.trim(),
        tenantContact: _tenantContactCtrl.text.trim(),
        leaseStartDate: _leaseStartDate!,
        leaseTermMonths: _leaseTermMonths,
        monthlyRent: rent,
        securityDeposit: deposit,
        utilitiesResponsibility: _utilitiesResponsibility,
        petsAllowed: _petsAllowed,
        specialNotes: _specialNotesCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/L-27',
        arguments: {'packetId': packet.id},
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class LeasePacketSuggestionReviewScreen extends ConsumerStatefulWidget {
  final String packetId;

  const LeasePacketSuggestionReviewScreen({
    super.key,
    required this.packetId,
  });

  @override
  ConsumerState<LeasePacketSuggestionReviewScreen> createState() =>
      _LeasePacketSuggestionReviewScreenState();
}

class _LeasePacketSuggestionReviewScreenState
    extends ConsumerState<LeasePacketSuggestionReviewScreen> {
  LeasePacket? _packet;
  bool _loading = true;
  String? _error;

  final _leaseEndCtrl = TextEditingController();
  final _rentDueDayCtrl = TextEditingController();
  final _lateFeeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _leaseEndCtrl.dispose();
    _rentDueDayCtrl.dispose();
    _lateFeeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review suggestions'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ErrorBanner(message: _error!),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _packet == null
                    ? const Center(
                        child: Text('Lease packet not found.'),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            'AYRNOW suggested the remaining lease details. Adjust anything before you continue.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          _SummaryRow(
                            label: 'Tenant',
                            value: '${_packet!.tenantName} • ${_packet!.tenantContact}',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Start date',
                            value: _packet!.leaseStartDate != null
                                ? DateFormat.yMMMd().format(_packet!.leaseStartDate!)
                                : 'Not set',
                          ),
                          const SizedBox(height: 16),
                          _DateField(
                            label: 'Lease end date (suggested)',
                            value: _packet!.leaseEndDate,
                            onChanged: (d) {
                              setState(() {
                                _packet = LeasePacket(
                                  id: _packet!.id,
                                  unitId: _packet!.unitId,
                                  tenantName: _packet!.tenantName,
                                  tenantContact: _packet!.tenantContact,
                                  leaseStartDate: _packet!.leaseStartDate,
                                  leaseEndDate: d,
                                  monthlyRent: _packet!.monthlyRent,
                                  securityDeposit: _packet!.securityDeposit,
                                  leaseTermMonths: _packet!.leaseTermMonths,
                                  utilitiesResponsibility:
                                      _packet!.utilitiesResponsibility,
                                  petsAllowed: _packet!.petsAllowed,
                                  specialNotes: _packet!.specialNotes,
                                  rentDueDay: _packet!.rentDueDay,
                                  lateFeeClause: _packet!.lateFeeClause,
                                  documentRequirements:
                                      _packet!.documentRequirements,
                                  inviteSteps: _packet!.inviteSteps,
                                  status: _packet!.status,
                                  inviteId: _packet!.inviteId,
                                  inviteUrlToken: _packet!.inviteUrlToken,
                                  tenantTypedName: _packet!.tenantTypedName,
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _rentDueDayCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Rent due day (1–28)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lateFeeCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Late fee clause (suggested)',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _loading ? null : _saveAndNext,
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Continue to documents'),
                          ),
                        ],
                      ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final packet = await api.getPacket(widget.packetId);
      _leaseEndCtrl.text = packet.leaseEndDate != null
          ? DateFormat.yMMMd().format(packet.leaseEndDate!)
          : '';
      _rentDueDayCtrl.text =
          packet.rentDueDay != null ? packet.rentDueDay.toString() : '';
      _lateFeeCtrl.text = packet.lateFeeClause ?? '';
      setState(() {
        _packet = packet;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveAndNext() async {
    if (_packet == null) return;
    int? rentDay;
    if (_rentDueDayCtrl.text.trim().isNotEmpty) {
      rentDay = int.tryParse(_rentDueDayCtrl.text.trim());
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final updated = await api.updatePacket(
        packetId: _packet!.id,
        leaseEndDate: _packet!.leaseEndDate,
        rentDueDay: rentDay,
        lateFeeClause: _lateFeeCtrl.text.trim().isEmpty
            ? null
            : _lateFeeCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/L-28',
        arguments: {'packetId': updated.id},
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

class LeasePacketDocumentsScreen extends ConsumerStatefulWidget {
  final String packetId;

  const LeasePacketDocumentsScreen({
    super.key,
    required this.packetId,
  });

  @override
  ConsumerState<LeasePacketDocumentsScreen> createState() =>
      _LeasePacketDocumentsScreenState();
}

class _LeasePacketDocumentsScreenState
    extends ConsumerState<LeasePacketDocumentsScreen> {
  LeasePacket? _packet;
  bool _loading = true;
  String? _error;

  final List<TenantDocumentRequirement> _editableDocs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Required documents'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ErrorBanner(message: _error!),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: _editableDocs.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No document checklist yet. Add at least ID and proof of income.',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _editableDocs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final d = _editableDocs[index];
                                  return _DocumentRequirementTile(
                                    requirement: d,
                                    onChanged: (updated) {
                                      setState(() {
                                        _editableDocs[index] = updated;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _addCustom,
                              icon: const Icon(Icons.add),
                              label: const Text('Add custom document'),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _loading ? null : _saveAndNext,
                              icon: const Icon(Icons.send_outlined),
                              label:
                                  const Text('Review & send invite summary'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final packet = await api.getPacket(widget.packetId);
      setState(() {
        _packet = packet;
        _editableDocs
          ..clear()
          ..addAll(packet.documentRequirements);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addCustom() {
    setState(() {
      _editableDocs.add(
        TenantDocumentRequirement(
          id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
          label: 'Additional document',
          required: false,
          status: 'required',
          filename: null,
          rejectionReason: null,
        ),
      );
    });
  }

  Future<void> _saveAndNext() async {
    if (_packet == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final updated = await api.updatePacket(
        packetId: _packet!.id,
        documentRequirements: List.of(_editableDocs),
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/L-29',
        arguments: {'packetId': updated.id},
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

class LeasePacketSendInviteScreen extends ConsumerStatefulWidget {
  final String packetId;

  const LeasePacketSendInviteScreen({
    super.key,
    required this.packetId,
  });

  @override
  ConsumerState<LeasePacketSendInviteScreen> createState() =>
      _LeasePacketSendInviteScreenState();
}

class _LeasePacketSendInviteScreenState
    extends ConsumerState<LeasePacketSendInviteScreen> {
  LeasePacket? _packet;
  bool _loading = true;
  String? _error;
  bool _sending = false;
  bool _sent = false;

  final Map<String, bool> _docApproved = {};
  final Map<String, TextEditingController> _docReasonCtrls = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & send invite'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ErrorBanner(message: _error!),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _packet == null
                    ? const Center(child: Text('Lease packet not found.'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            'Send a guided onboarding packet to your tenant. They\'ll review the lease, upload documents, and submit everything back to you.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          _SummaryRow(
                            label: 'Tenant',
                            value:
                                '${_packet!.tenantName} • ${_packet!.tenantContact}',
                          ),
                          const SizedBox(height: 8),
                          if (_packet!.leaseStartDate != null &&
                              _packet!.leaseEndDate != null)
                            _SummaryRow(
                              label: 'Term',
                              value:
                                  '${DateFormat.yMMMd().format(_packet!.leaseStartDate!)} – ${DateFormat.yMMMd().format(_packet!.leaseEndDate!)}',
                            )
                          else
                            _SummaryRow(
                              label: 'Start date',
                              value: _packet!.leaseStartDate != null
                                  ? DateFormat.yMMMd()
                                      .format(_packet!.leaseStartDate!)
                                  : 'Not set',
                            ),
                          const SizedBox(height: 8),
                          if (_packet!.monthlyRent != null)
                            _SummaryRow(
                              label: 'Monthly rent',
                              value: _currencyFormatter
                                  .format(_packet!.monthlyRent),
                            ),
                          if (_packet!.securityDeposit != null)
                            _SummaryRow(
                              label: 'Security deposit',
                              value: _currencyFormatter
                                  .format(_packet!.securityDeposit),
                            ),
                          const SizedBox(height: 8),
                          if (_packet!.rentDueDay != null)
                            _SummaryRow(
                              label: 'Rent due day',
                              value: 'Day ${_packet!.rentDueDay}',
                            ),
                          const SizedBox(height: 16),
                          Text(
                            'Required documents',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_packet!.documentRequirements.isEmpty)
                            const Text('No documents configured.')
                          else
                            Column(
                              children: _packet!.documentRequirements
                                  .map(
                                    (d) => ListTile(
                                      dense: true,
                                      leading: Icon(
                                        d.required
                                            ? Icons.check_circle_outline
                                            : Icons.radio_button_unchecked,
                                      ),
                                      title: Text(d.label),
                                      subtitle: Text(
                                          d.required ? 'Required' : 'Optional'),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 24),
                          _reviewSection(Theme.of(context).textTheme),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            _ErrorBanner(message: _error!),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _sending || _sent ? null : _sendInvite,
                            icon: _sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(
                                _sent ? 'Invite sent' : 'Send invite to tenant'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                ModalRoute.withName('/L-50'),
                              );
                            },
                            child: const Text('Back to residents'),
                          ),
                        ],
                      ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final packet = await api.getPacket(widget.packetId);
      setState(() {
        _packet = packet;
        _initialiseReviewState(packet);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _initialiseReviewState(LeasePacket packet) {
    for (final d in packet.documentRequirements) {
      _docApproved[d.id] = d.status == 'approved';
      _docReasonCtrls.putIfAbsent(
        d.id,
        () => TextEditingController(text: d.rejectionReason ?? ''),
      );
    }
  }

  Future<void> _sendInvite() async {
    final packet = _packet;
    if (packet == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final token = ref.read(authTokenProvider);
      final inviteApi = InviteApi(() => token);
      final invite = await inviteApi.createUnitInvite(
        unitId: packet.unitId,
        contactType: 'email', // MVP: treat contact as email-like
        contactValue: packet.tenantContact,
        role: 'tenant',
      );
      if (invite.inviteUrlToken == null || invite.inviteUrlToken!.isEmpty) {
        throw Exception('Invite did not include an invite link token.');
      }
      final onboardingApi = ref.read(leaseOnboardingApiProvider);
      await onboardingApi.attachInvite(
        packetId: packet.id,
        inviteId: invite.id,
        inviteUrlToken: invite.inviteUrlToken!,
      );
      if (!mounted) return;
      setState(() {
        _sent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lease onboarding invite sent to tenant.'),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Widget _reviewSection(TextTheme theme) {
    final p = _packet!;
    final isReviewStage =
        p.status == 'under_review' || p.status == 'rejected' || p.status == 'approved';
    if (!isReviewStage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review (once tenant submits)', style: theme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'When your tenant finishes their checklist and submits everything, you can review documents here.',
            style: theme.bodySmall,
          ),
        ],
      );
    }

    String statusLabel;
    if (p.status == 'approved') {
      statusLabel = 'Packet approved';
    } else if (p.status == 'rejected') {
      statusLabel = 'Changes requested';
    } else {
      statusLabel = 'Awaiting your decision';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Landlord review', style: theme.titleMedium),
        const SizedBox(height: 4),
        Text(statusLabel, style: theme.bodySmall),
        const SizedBox(height: 12),
        ...p.documentRequirements.map((d) {
          final reasonCtrl = _docReasonCtrls[d.id]!;
          final approved = _docApproved[d.id] ?? (d.status == 'approved');
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.label, style: theme.bodyMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Approve'),
                        selected: approved,
                        onSelected: (v) {
                          setState(() {
                            _docApproved[d.id] = true;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Request changes'),
                        selected: !approved,
                        onSelected: (v) {
                          setState(() {
                            _docApproved[d.id] = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (!approved)
                    TextField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reason (shared with tenant)',
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _submitReview,
          icon: const Icon(Icons.checklist),
          label: const Text('Save review decision'),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    final p = _packet;
    if (p == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final decisions = <LeaseReviewDecision>[];
      bool anyRejected = false;
      for (final d in p.documentRequirements) {
        final approved = _docApproved[d.id] ?? (d.status == 'approved');
        final reason = _docReasonCtrls[d.id]?.text;
        if (!approved) {
          anyRejected = true;
        }
        decisions.add(LeaseReviewDecision(
          id: d.id,
          approved: approved,
          reason: approved ? null : reason,
        ));
      }
      final api = ref.read(leaseOnboardingApiProvider);
      final updated = await api.reviewPacket(
        packetId: p.id,
        approved: !anyRejected,
        documentDecisions: decisions,
      );
      setState(() {
        _packet = updated;
        _initialiseReviewState(updated);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(anyRejected
                ? 'Sent changes requested back to tenant.'
                : 'Approved onboarding packet.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: value != null ? DateFormat.yMMMd().format(value!) : '',
    );
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 5),
        );
        onChanged(picked);
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? prefixText;
  final String? Function(String?)? validator;

  const _NumberField({
    required this.controller,
    required this.label,
    this.prefixText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
      ),
      validator: validator,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentRequirementTile extends StatelessWidget {
  final TenantDocumentRequirement requirement;
  final ValueChanged<TenantDocumentRequirement> onChanged;

  const _DocumentRequirementTile({
    required this.requirement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelCtrl = TextEditingController(text: requirement.label);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Document name',
                ),
                onChanged: (v) {
                  onChanged(requirement.copyWith(label: v));
                },
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                const Text('Required'),
                Switch(
                  value: requirement.required,
                  onChanged: (v) {
                    onChanged(requirement.copyWith(required: v));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

