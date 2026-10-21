import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const SignUpScreen(),
      );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers, key and focus node: created once, live in State.
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passLen = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  String _fmt(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  // Validators: the rule lives beside the field it guards.
  String? _validateName(String? v) =>
      (v ?? '').trim().length < 2 ? 'Name is too short' : null;

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    final at = s.indexOf('@');
    return at > 0 && s.indexOf('.', at) > at ? null : 'Email looks wrong';
  }

  String? _validatePassword(String? v) =>
      (v ?? '').length < 8 ? 'Password is too short' : null;

  String? _validateConfirm(String? v) =>
      v == _password.text ? null : 'Passwords do not match';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return; // Cancel: keep the old value
    if (!mounted) return; // the user may have left
    setState(() {
      _birth = picked;
      _birthText.text = _fmt(picked);
    });
  }

  void _submit() {
    _unfocus();
    final valid = _formKey.currentState!.validate();
    if (valid && _agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      setState(() => _done = true);
    }
  }

  void _startOver() {
    // Do not touch _formKey.currentState here: the Form is not on screen.
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passLen = 0;
      _done = false;
    });
  }

  Widget _buildForm() => Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              onTapOutside: (_) => _unfocus(),
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => _unfocus(),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              onChanged: (v) => setState(() => _passLen = v.length),
              onTapOutside: (_) => _unfocus(),
              validator: _validatePassword,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text('$_passLen of 8'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              onTapOutside: (_) => _unfocus(),
              validator: _validateConfirm,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _group,
              decoration: const InputDecoration(labelText: 'Group'),
              items: [
                for (final g in groups)
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (g) => setState(() => _group = g),
              validator: (g) => g == null ? 'Choose a group' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthText,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
              validator: (_) => _birth != null ? null : 'Pick a date',
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('I agree to the rules'),
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _agreed ? _submit : null,
              child: const Text('Sign up'),
            ),
          ],
        ),
      );

  Widget _buildSummary() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SummaryCard(
            name: _name.text.trim(),
            email: _email.text.trim(),
            group: _group ?? '',
            birth: _birthText.text,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _startOver,
            child: const Text('Start over'),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sign up')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _done ? _buildSummary() : _buildForm(),
        ),
      );
}
