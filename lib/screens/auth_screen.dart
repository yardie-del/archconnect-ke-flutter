import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/architect_tier.dart';
import '../widgets/wallet_helpers.dart';

enum _AuthMode { signIn, signUp, forgotPassword }

/// Dart port of the Kotlin `AuthScreen`. Handles both Client and Architect
/// sign-up (with role-specific fields), and sign-in, producing an [AppUser]
/// on success. Password recovery is a stub (no real backend yet).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthSuccess});

  final ValueChanged<AppUser> onAuthSuccess;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMode _mode = _AuthMode.signIn;
  UserRole _selectedRole = UserRole.client;
  String? _error;

  // Shared fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;

  // Client fields
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController(text: '+254 ');
  final _clientLocationController = TextEditingController(text: 'Nairobi, Kenya');

  // Architect fields
  final _architectNameController = TextEditingController();
  final _firmNameController = TextEditingController();
  final _boraqsController = TextEditingController();
  final _architectPhoneController = TextEditingController(text: '+254 ');
  final _architectLocationController = TextEditingController(text: 'Nairobi, Kenya');
  final _bioController = TextEditingController();
  ArchitectTier _architectTier = ArchitectTier.gold;

  static const _availableServices = [
    'House Plans',
    '3D Renders',
    'County Approvals',
    'Structural Drawings',
    'Interior Design',
    'Quantity Surveying',
    'Landscape Architecture',
    'Site Supervision',
  ];
  final Set<String> _selectedServices = {'House Plans', '3D Renders', 'County Approvals'};

  @override
  void dispose() {
    for (final c in [
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _clientNameController,
      _clientPhoneController,
      _clientLocationController,
      _architectNameController,
      _firmNameController,
      _boraqsController,
      _architectPhoneController,
      _architectLocationController,
      _bioController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ArchConnect KE Auth')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 14),
          _buildRoleToggle(),
          const SizedBox(height: 14),
          if (_mode != _AuthMode.forgotPassword) ...[
            _buildModeToggle(),
            const SizedBox(height: 14),
          ],
          if (_mode == _AuthMode.signUp) _buildRoleSpecificFields(),
          _buildSharedFields(),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: kenyaRed, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kenyaGreenPrimary),
              onPressed: _submit,
              child: Text(
                switch (_mode) {
                  _AuthMode.signIn => 'Sign In',
                  _AuthMode.signUp => 'Create Account',
                  _AuthMode.forgotPassword => 'Send Reset Link',
                },
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_mode == _AuthMode.signIn)
            TextButton(
              onPressed: () => setState(() => _mode = _AuthMode.forgotPassword),
              child: const Text('Forgot password?', style: TextStyle(color: slateMuted)),
            )
          else if (_mode == _AuthMode.forgotPassword)
            TextButton(
              onPressed: () => setState(() => _mode = _AuthMode.signIn),
              child: const Text('Back to Sign In', style: TextStyle(color: slateMuted)),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    final isClient = _selectedRole == UserRole.client;
    return Card(
      color: slateDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isClient ? 'Client Portal Account' : 'Architect Professional Pro',
                    style: const TextStyle(color: safariGold, fontWeight: FontWeight.bold, fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isClient ? kenyaGreenPrimary : const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isClient ? 'ESCROW SECURE' : 'BORAQS VERIFIED',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              switch (_mode) {
                _AuthMode.signIn => "Welcome Back to Kenya's Premier Architect Network",
                _AuthMode.signUp => isClient
                    ? 'Hire Verified Kenyan Architects with Escrow Safety'
                    : "Join Kenya's Architectural Marketplace & Win Projects",
                _AuthMode.forgotPassword => 'Recover Your Account Password',
              },
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              isClient
                  ? 'Protect your project budget with bank-held escrow milestones and verified CAD drawings.'
                  : 'Showcase your portfolio, bid on residential & commercial briefs, and receive bank payouts.',
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.client, label: Text('Client'), icon: Icon(Icons.person)),
        ButtonSegment(value: UserRole.architect, label: Text('Architect'), icon: Icon(Icons.architecture)),
      ],
      selected: {_selectedRole},
      onSelectionChanged: (s) => setState(() => _selectedRole = s.first),
    );
  }

  Widget _buildModeToggle() {
    return SegmentedButton<_AuthMode>(
      segments: const [
        ButtonSegment(value: _AuthMode.signIn, label: Text('Sign In')),
        ButtonSegment(value: _AuthMode.signUp, label: Text('Sign Up')),
      ],
      selected: {_mode},
      onSelectionChanged: (s) => setState(() => _mode = s.first),
    );
  }

  Widget _buildRoleSpecificFields() {
    if (_selectedRole == UserRole.client) {
      return Column(
        children: [
          TextField(
            controller: _clientNameController,
            decoration: const InputDecoration(labelText: 'Full Name *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _clientPhoneController,
            decoration: const InputDecoration(labelText: 'Phone Number *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _clientLocationController,
            decoration: const InputDecoration(labelText: 'Location *'),
          ),
          const SizedBox(height: 12),
        ],
      );
    }
    return Column(
      children: [
        TextField(controller: _architectNameController, decoration: const InputDecoration(labelText: 'Full Name *')),
        const SizedBox(height: 8),
        TextField(controller: _firmNameController, decoration: const InputDecoration(labelText: 'Firm / Practice Name *')),
        const SizedBox(height: 8),
        const Align(alignment: Alignment.centerLeft, child: Text('Professional Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        Wrap(
          spacing: 8,
          children: ArchitectTier.values.map((t) {
            return ChoiceChip(
              label: Text(t.title, style: const TextStyle(fontSize: 11)),
              selected: _architectTier == t,
              onSelected: (_) => setState(() => _architectTier = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(controller: _boraqsController, decoration: const InputDecoration(labelText: 'BORAQS Number / College ID')),
        const SizedBox(height: 8),
        TextField(controller: _architectPhoneController, decoration: const InputDecoration(labelText: 'Phone Number *')),
        const SizedBox(height: 8),
        TextField(controller: _architectLocationController, decoration: const InputDecoration(labelText: 'Location *')),
        const SizedBox(height: 8),
        TextField(controller: _bioController, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Short Bio')),
        const SizedBox(height: 8),
        const Align(alignment: Alignment.centerLeft, child: Text('Services Offered:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableServices.map((s) {
            final selected = _selectedServices.contains(s);
            return FilterChip(
              label: Text(s, style: const TextStyle(fontSize: 11)),
              selected: selected,
              onSelected: (v) => setState(() => v ? _selectedServices.add(s) : _selectedServices.remove(s)),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSharedFields() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email *'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password *',
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
        ),
        if (_mode == _AuthMode.signUp) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_passwordVisible,
            decoration: const InputDecoration(labelText: 'Confirm Password *'),
          ),
        ],
      ],
    );
  }

  void _submit() {
    setState(() => _error = null);

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Email and password are required.');
      return;
    }

    if (_mode == _AuthMode.forgotPassword) {
      setState(() => _error = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent (simulated).')),
      );
      return;
    }

    if (_mode == _AuthMode.signUp && _passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    final isClient = _selectedRole == UserRole.client;
    if (_mode == _AuthMode.signUp) {
      final name = isClient ? _clientNameController.text.trim() : _architectNameController.text.trim();
      if (name.isEmpty) {
        setState(() => _error = 'Full name is required.');
        return;
      }
    }

    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: isClient
          ? (_clientNameController.text.trim().isNotEmpty ? _clientNameController.text.trim() : 'Client User')
          : (_architectNameController.text.trim().isNotEmpty ? _architectNameController.text.trim() : 'Architect User'),
      email: _emailController.text.trim(),
      phone: isClient ? _clientPhoneController.text.trim() : _architectPhoneController.text.trim(),
      location: isClient ? _clientLocationController.text.trim() : _architectLocationController.text.trim(),
      role: _selectedRole,
      bio: isClient ? '' : _bioController.text.trim(),
      firmName: isClient ? '' : _firmNameController.text.trim(),
      tier: isClient ? null : _architectTier,
      boraqsNumber: isClient ? '' : _boraqsController.text.trim(),
      services: isClient ? const [] : _selectedServices.toList(),
    );

    widget.onAuthSuccess(user);
  }
}