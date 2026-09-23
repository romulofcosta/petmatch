import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/services/geolocation_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/pets_provider.dart';

class AddPetPage extends ConsumerStatefulWidget {
  const AddPetPage({super.key});

  @override
  ConsumerState<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends ConsumerState<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _breedController = TextEditingController();

  String _selectedType = 'dog';
  String _selectedSex = 'male';
  String _selectedBreedGroup = '';
  DateTime? _birthDate;
  List<String> _selectedInterests = [];
  List<String> _selectedPersonalityTags = [];

  static const _breedGroups = {
    'dog': [
      'Pequeno',
      'Médio',
      'Grande',
      'Gigante',
    ],
    'cat': [
      'Puro',
      'Mestiço',
    ],
  };

  static const _personalityTags = [
    'Brincalhão',
    'Calmo',
    'Carinhoso',
    'Sociável',
    'Guardião',
    'Independente',
    'Aventureiro',
    'Manso',
    'Esperto',
    'Persistente',
  ];

  static const _interestOptions = [
    ('socialization', 'Socialização'),
    ('breeding', 'Reprodução'),
    ('adoption', 'Adoção'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedType = value;
        _selectedBreedGroup = '';
        _breedController.clear();
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final minDate = DateTime(now.year - 15, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 1, now.month, now.day),
      firstDate: minDate,
      lastDate: DateTime(now.year, now.month, now.day - 4),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento')),
      );
      return;
    }

    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um interesse')),
      );
      return;
    }

    final location = await const GeolocationService().getCurrentPosition();
    if (!mounted) return;

    if (location.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Precisamos da sua localização para encontrar pets próximos. '
            'Permita o acesso à localização e tente novamente.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final pet = await ref.read(petFormProvider.notifier).createPet(
          name: _nameController.text.trim(),
          type: _selectedType,
          sex: _selectedSex,
          breed: _breedController.text.trim(),
          breedGroup: _selectedBreedGroup,
          birthDate: _birthDate!,
          interests: _selectedInterests,
          mainPhotoUrl: 'https://placehold.co/400x400?text=Pet',
          latitude: location.latitude,
          longitude: location.longitude,
          weightKg: double.tryParse(_weightController.text),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          personalityTags:
              _selectedPersonalityTags.isEmpty ? null : _selectedPersonalityTags,
        );

    if (pet != null && mounted) {
      ref.invalidate(myPetsProvider);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pet.name} cadastrado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(petFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Pet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Nome do pet',
              hint: 'Ex: Rex, Mimi, Luna',
              controller: _nameController,
              validator: Validators.petName,
              prefixIcon: const Icon(Icons.pets),
              maxLength: 30,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'dog', child: Text('Cachorro')),
                DropdownMenuItem(value: 'cat', child: Text('Gato')),
              ],
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSex,
              decoration: const InputDecoration(
                labelText: 'Sexo',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Macho')),
                DropdownMenuItem(value: 'female', child: Text('Fêmea')),
              ],
              onChanged: (v) => setState(() => _selectedSex = v ?? 'male'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Raça',
              hint: 'Ex: Labrador, Persa, SRD',
              controller: _breedController,
              validator: Validators.required,
              prefixIcon: const Icon(Icons.search),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedBreedGroup.isEmpty
                  ? null
                  : _selectedBreedGroup,
              decoration: const InputDecoration(
                labelText: 'Grupo / Porte',
                prefixIcon: Icon(Icons.straighten),
                border: OutlineInputBorder(),
              ),
              items: (_breedGroups[_selectedType] ?? [])
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBreedGroup = v ?? ''),
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de nascimento'),
              subtitle: Text(
                _birthDate != null
                    ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                    : 'Toque para selecionar',
                style: TextStyle(
                  color: _birthDate != null ? null : AppColors.textSecondary,
                ),
              ),
              leading: const Icon(Icons.cake),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectBirthDate,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Peso (kg)',
              hint: 'Ex: 12.5',
              controller: _weightController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final weight = double.tryParse(v);
                if (weight == null ||
                    weight < AppConstants.minWeight ||
                    weight > AppConstants.maxWeight) {
                  return 'Peso entre ${AppConstants.minWeight} e ${AppConstants.maxWeight} kg';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Descrição',
              hint: 'Conte um pouco sobre o pet...',
              controller: _descriptionController,
              maxLines: 3,
              maxLength: AppConstants.maxDescriptionLength,
              prefixIcon: const Icon(Icons.description),
            ),
            const SizedBox(height: 24),
            Text(
              'Interesses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interestOptions.map((option) {
                final isSelected = _selectedInterests.contains(option.$1);
                return FilterChip(
                  label: Text(option.$2),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(option.$1);
                      } else {
                        _selectedInterests.remove(option.$1);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Personalidade',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _personalityTags.map((tag) {
                final isSelected = _selectedPersonalityTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPersonalityTags.add(tag);
                      } else {
                        _selectedPersonalityTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Cadastrar Pet',
              isLoading: formState is AsyncLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
