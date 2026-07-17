import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _role = AppUser.roleCustomer;
  bool _agreed = false;
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_agreed) {
      setState(() => _error = 'Please agree to the Terms of Service.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
        agencyName: _role == AppUser.roleAgency ? _agencyNameController.text.trim() : null,
      );
      // main.dart's authStateChanges() listener takes it from here.
    } catch (e) {
      setState(() => _error = 'Could not create account: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Shared by every TextField below, so the same visible border doesn't
  // need to be repeated five times.
  InputDecoration _borderedDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0F6E56), width: 1.5),
      ),
    );
  }

  Widget _roleOption(String role, IconData icon, String label) {
    final selected = _role == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _role = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5EE) : const Color(0xFFF4F5F4),
            border: Border.all(color: selected ? const Color(0xFF0F6E56) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? const Color(0xFF0F6E56) : Colors.grey),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? const Color(0xFF0F6E56) : Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('I am a...', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _roleOption(AppUser.roleCustomer, Icons.person_outline, 'Customer'),
                  const SizedBox(width: 8),
                  _roleOption(AppUser.roleAgency, Icons.storefront_outlined, 'Travel agency'),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: _borderedDecoration('Full name'),
              ),
              // Only shown when "Travel agency" is selected — this is what
              // creates the companies/{companyId} doc on submit.
              if (_role == AppUser.roleAgency) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _agencyNameController,
                  decoration: _borderedDecoration('Agency name'),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _borderedDecoration('Email'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _borderedDecoration('Password'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: _borderedDecoration('Confirm password'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false)),
                  const Expanded(
                    child: Text('I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}