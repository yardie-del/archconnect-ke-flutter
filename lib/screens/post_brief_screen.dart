import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project_brief.dart';
import '../widgets/escrow_protection_banner.dart';
import '../widgets/wallet_helpers.dart';

/// Dart port of the Kotlin `PostBriefScreen`.
///
/// A client fills this in to post a project brief that verified BORAQS
/// architects can then bid on. Calls [onBriefPosted] with the completed
/// [ProjectBrief] on submit, or [onCancel] if the client backs out.
class PostBriefScreen extends StatefulWidget {
  const PostBriefScreen({
    super.key,
    required this.onBriefPosted,
    required this.onCancel,
  });

  final ValueChanged<ProjectBrief> onBriefPosted;
  final VoidCallback onCancel;

  @override
  State<PostBriefScreen> createState() => _PostBriefScreenState();
}

class _PostBriefScreenState extends State<PostBriefScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Karen, Nairobi');
  final _budgetMinController = TextEditingController(text: '150000');
  final _budgetMaxController = TextEditingController(text: '250000');
  final _deadlineDaysController = TextEditingController(text: '14');

  ProjectCategory _selectedCategory = ProjectCategory.housePlan;

  static const _kenyanLocations = [
    'Karen, Nairobi',
    'Westlands, Nairobi',
    'Runda, Nairobi',
    'Kilimani, Nairobi',
    'Ruaka / Kiambu Road',
    'Nyali, Mombasa',
    'Milimani, Nakuru',
    'Riat Hills, Kisumu',
    'Elgon View, Eldoret',
    'Naivasha Sanctuary',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _deadlineDaysController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty && _descriptionController.text.trim().isNotEmpty;

  void _submit() {
    if (!_isValid) return;
    final brief = ProjectBrief(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      budgetMinKsh: int.tryParse(_budgetMinController.text) ?? 50000,
      budgetMaxKsh: int.tryParse(_budgetMaxController.text) ?? 150000,
      deadlineDays: int.tryParse(_deadlineDaysController.text) ?? 14,
    );
    widget.onBriefPosted(brief);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Brief')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Post Architectural Project Brief',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: slateDark),
          ),
          const SizedBox(height: 2),
          const Text(
            'Verified BORAQS architects will submit competitive bids with price & timeline.',
            style: TextStyle(fontSize: 12, color: slateMuted),
          ),
          const SizedBox(height: 16),
          const EscrowProtectionBanner(),
          const SizedBox(height: 16),

          // Project Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Project Title *',
              hintText: 'e.g. Modern 4-Bedroom Eco-Villa with Solar Design',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Category picker
          const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: slateDark)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ProjectCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = ProjectCategory.values[i];
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat.displayName, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  selectedColor: kenyaGreenPrimary,
                  labelStyle: TextStyle(color: selected ? Colors.white : slateDark),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Location
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _locationController.text),
            optionsBuilder: (v) => v.text.isEmpty
                ? _kenyanLocations
                : _kenyanLocations.where((l) => l.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (v) => _locationController.text = v,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              controller.text = _locationController.text;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'Location (County / Estate) *'),
                onChanged: (v) => _locationController.text = v,
              );
            },
          ),
          const SizedBox(height: 12),

          // Budget min/max
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _budgetMinController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Budget Min (Ksh)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _budgetMaxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Budget Max (Ksh)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deadline
          TextField(
            controller: _deadlineDaysController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Estimated Delivery Target (Days)'),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Project Brief & Deliverable Requirements *',
              hintText: 'Describe the plot size, room requirements, county permitting '
                  'needs, design aesthetics, or any specific constraints...',
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isValid ? _submit : null,
              style: FilledButton.styleFrom(backgroundColor: kenyaGreenPrimary),
              icon: const Icon(Icons.send),
              label: const Text('Post Brief to Verified Architects', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel', style: TextStyle(color: slateMuted)),
            ),
          ),
        ],
      ),
    );
  }
}