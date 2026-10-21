import 'package:flutter/material.dart';

import '../models/event_category.dart';
import '../models/item.dart';
import '../utils/format.dart';

TimeOfDay? _initialTime(Item? item) =>
    item == null ? null : TimeOfDay.fromDateTime(item.when);
String _initialDate(Item? item) =>
    item == null ? '' : formatDateTime(item.when);
String _initialTimeText(Item? item) => item == null
    ? ''
    : '${item.when.hour.toString().padLeft(2, '0')}:${item.when.minute.toString().padLeft(2, '0')}';

class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, this.item, required this.currentCount});
  final Item? item;
  final int currentCount;
  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.item?.title ?? '');
  late final _place = TextEditingController(text: widget.item?.location ?? '');
  late final _limit = TextEditingController(
    text: '${widget.item?.limit ?? 20}',
  );
  late final _description = TextEditingController(
    text: widget.item?.description ?? '',
  );
  late final _dateInput = TextEditingController(
    text: _initialDate(widget.item),
  );
  late final _timeInput = TextEditingController(
    text: _initialTimeText(widget.item),
  );
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  late EventCategory? _category = widget.item?.category;
  late bool _online = widget.item?.isOnline ?? false;
  late DateTime? _date = widget.item?.when;
  late TimeOfDay? _time = _initialTime(widget.item);
  bool _saving = false;
  String get _locationLabel => _online ? 'Online link' : 'Place';
  bool get _dirty {
    final original = widget.item;
    final date = _date;
    final time = _time;
    return _title.text != (original?.title ?? '') ||
        _place.text != (original?.location ?? '') ||
        _limit.text != '${original?.limit ?? 20}' ||
        _description.text != (original?.description ?? '') ||
        _category != original?.category ||
        _online != (original?.isOnline ?? false) ||
        (date?.year != original?.when.year ||
            date?.month != original?.when.month ||
            date?.day != original?.when.day) ||
        time?.hour != original?.when.hour ||
        time?.minute != original?.when.minute;
  }

  @override
  void initState() {
    super.initState();
    for (final c in [
      _title,
      _place,
      _limit,
      _description,
      _dateInput,
      _timeInput,
    ]) {
      c.addListener(_changed);
    }
  }

  void _changed() => setState(() {});
  @override
  void dispose() {
    for (final c in [_title, _place, _limit, _description]) {
      c.removeListener(_changed);
      c.dispose();
    }
    for (final f in [
      _titleFocus,
      _placeFocus,
      _limitFocus,
      _descriptionFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _leave() async {
    if (!_dirty || _saving) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted || discard != true) return;
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final earliestDate = widget.item == null ? DateTime.now() : DateTime(1970);
    final value = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: earliestDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (!mounted || value == null) return;
    setState(() {
      _date = value;
      _dateInput.text = formatDateTime(value);
    });
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (!mounted || value == null) return;
    setState(() {
      _time = value;
      _timeInput.text =
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false) ||
        _category == null ||
        _date == null ||
        _time == null) {
      if (_category == null || _date == null || _time == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose a category, date and time.')),
        );
      }
      return;
    }
    final date = _date;
    final time = _time;
    final category = _category;
    if (date == null || time == null || category == null) return;
    final starts = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (widget.item == null && !starts.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future date and time.')),
      );
      return;
    }
    setState(() => _saving = true);
    final result = (widget.item ?? Item.empty()).copyWith(
      title: _title.text.trim(),
      category: category,
      when: starts,
      limit: int.parse(_limit.text),
      location: _place.text.trim(),
      isOnline: _online,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      clearDescription: _description.text.trim().isEmpty,
      attendees: widget.item?.attendees ?? const [],
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty && !_saving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _leave();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New event' : 'Edit event'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().length < 3 || v.trim().length > 60
                    ? 'Enter 3–60 characters'
                    : null,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: EventCategory.values
                    .map(
                      (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Choose a category' : null,
              ),
              SwitchListTile(
                title: const Text('Online event'),
                value: _online,
                onChanged: (v) => setState(() => _online = v),
              ),
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                keyboardType: _online
                    ? TextInputType.url
                    : TextInputType.streetAddress,
                decoration: InputDecoration(
                  labelText: _locationLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (_online && !v.contains('://')) {
                    return 'Enter a link containing ://';
                  }
                  return null;
                },
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limit,
                focusNode: _limitFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 500) {
                    return 'Enter a number from 1 to 500';
                  }
                  if (n < widget.currentCount) {
                    return 'Cannot be below current attendance (${widget.currentCount})';
                  }
                  return null;
                },
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateInput,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Choose a date'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _timeInput,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Choose a time'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
