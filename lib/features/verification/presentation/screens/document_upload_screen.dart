import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/verification_provider.dart';
import 'verification_payment_screen.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final String roleType;

  const DocumentUploadScreen({
    super.key,
    required this.roleType,
  });

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final _documentNumberController = TextEditingController();
  String _documentType = 'aadhaar';

  XFile? _front;
  XFile? _back;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isFront) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;

    setState(() {
      if (isFront) {
        _front = file;
      } else {
        _back = file;
      }
    });
  }

  Future<void> _submit() async {
    if (_front == null || _back == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both front and back images')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final useCase = ref.read(createVerificationRequestUseCaseProvider);
    final result = await useCase(
      roleType: widget.roleType,
      documentType: _documentType,
      documentNumber: _documentNumberController.text.trim().isEmpty
          ? null
          : _documentNumberController.text.trim(),
      front: _front!,
      back: _back!,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (request) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submitted: ${request.status}')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPaymentScreen(
              roleType: widget.roleType,
              verificationRequestId: request.id,
            ),
          ),
        );
      },
    );

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBackground,
                    AppColors.secondaryBackground,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                showGlow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientText(
                      'Verify as ${widget.roleType}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _documentType,
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'aadhaar', child: Text('Aadhaar')),
                        DropdownMenuItem(value: 'pan', child: Text('PAN')),
                        DropdownMenuItem(value: 'manual', child: Text('Manual')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _documentType = v);
                      },
                    ),
                    const SizedBox(height: AppDimensions.md),
                    TextField(
                      controller: _documentNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Document Number (optional)',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : () => _pick(true),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(_front == null ? 'Upload Front' : 'Front selected'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : () => _pick(false),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(_back == null ? 'Upload Back' : 'Back selected'),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit Verification'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
