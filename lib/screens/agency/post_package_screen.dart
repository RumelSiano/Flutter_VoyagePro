import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../models/package.dart';
import '../../services/crud_service.dart';
import '../../widgets/image_upload_field.dart';

class PostPackageScreen extends StatefulWidget {
  final String companyId;
  // When set, the screen edits this package instead of creating a new one.
  final Package? existingPackage;

  const PostPackageScreen({super.key, required this.companyId, this.existingPackage});

  bool get isEditing => existingPackage != null;

  @override
  State<PostPackageScreen> createState() => _PostPackageScreenState();
}

class _PostPackageScreenState extends State<PostPackageScreen> {
  final _crud = CrudService();
  late final TextEditingController _titleController;
  late final TextEditingController _overviewController;
  late final TextEditingController _priceController;
  late final TextEditingController _slotsController;
  late final TextEditingController _daysController;
  late final TextEditingController _nightsController;

  late String _category;
  String? _imageUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPackage;

    _titleController = TextEditingController(text: existing?.title ?? '');
    _overviewController = TextEditingController(text: existing?.overview ?? '');
    _priceController =
        TextEditingController(text: existing != null ? existing.pricePerPerson.toStringAsFixed(0) : '');
    // Editing keeps the original slotsTotal — slotsLeft (how many are
    // actually still bookable) isn't user-editable here, since it moves
    // independently as customers book.
    _slotsController =
        TextEditingController(text: existing != null ? existing.slotsTotal.toString() : '');
    _daysController =
        TextEditingController(text: existing != null ? existing.durationDays.toString() : '');
    _nightsController =
        TextEditingController(text: existing != null ? existing.durationNights.toString() : '');

    _category = existing?.category ?? 'City tour';
    _imageUrl = existing?.imageUrl;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final slotsTotal = int.tryParse(_slotsController.text) ?? 0;
      final existing = widget.existingPackage;

      if (widget.isEditing) {
        // If the agency increased the slot count, pass the difference along
        // to slotsLeft too, so new capacity is actually bookable. Shrinking
        // slotsTotal below what's already booked is left unhandled here —
        // out of scope for this form.
        final addedSlots = slotsTotal - existing!.slotsTotal;
        final newSlotsLeft = (existing.slotsLeft + addedSlots).clamp(0, slotsTotal);

        await _crud.updatePackage(existing.id!, {
          'title': _titleController.text.trim(),
          'category': _category,
          'overview': _overviewController.text.trim(),
          'imageUrl': _imageUrl ?? '',
          'pricePerPerson': double.tryParse(_priceController.text) ?? 0,
          'durationDays': int.tryParse(_daysController.text) ?? 0,
          'durationNights': int.tryParse(_nightsController.text) ?? 0,
          'slotsTotal': slotsTotal,
          'slotsLeft': newSlotsLeft,
          // updatePackage() already forces status back to pending — that's
          // intentional, edits always need re-approval.
        });
      } else {
        // One-time fetch of the agency's own company doc, just for its
        // name. Denormalized onto the package so package cards/lists
        // elsewhere don't need a nested query per item to show who posted it.
        final companySnapshot = await _crud.companyStream(widget.companyId).first;
        final companyName = Company.fromMap(
          companySnapshot.id,
          companySnapshot.data() ?? {},
        ).name;

        await _crud.createPackage(
          Package(
            companyId: widget.companyId,
            companyName: companyName,
            title: _titleController.text.trim(),
            category: _category,
            overview: _overviewController.text.trim(),
            imageUrl: _imageUrl ?? '',
            pricePerPerson: double.tryParse(_priceController.text) ?? 0,
            durationDays: int.tryParse(_daysController.text) ?? 0,
            durationNights: int.tryParse(_nightsController.text) ?? 0,
            slotsTotal: slotsTotal,
            slotsLeft: slotsTotal,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Package updated — resubmitted for review.'
                : 'Package submitted for review.'),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit package' : 'Post a package')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing
                  ? 'Editing this package sends it back for admin re-approval.'
                  : 'Submitted packages are reviewed before going live.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ImageUploadField(folder: 'packages', onUploaded: (url) => setState(() => _imageUrl = url)),
            if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Current photo is set — upload a new one only if you want to replace it.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 14),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Package title')),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'City tour', child: Text('City tour')),
                DropdownMenuItem(value: 'Beach and island', child: Text('Beach and island')),
                DropdownMenuItem(value: 'Adventure', child: Text('Adventure')),
              ],
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _overviewController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Overview — what's included"),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price per person'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _slotsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Available slots'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Days'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _nightsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nights'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF2DD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xFF9A6B0A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isEditing
                          ? 'Saving will move this package back to pending until re-approved.'
                          : 'This package will show as pending until an admin approves it.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9A6B0A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(widget.isEditing ? Icons.save_outlined : Icons.send),
                label: Text(widget.isEditing ? 'Save changes' : 'Submit for review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}