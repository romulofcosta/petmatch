import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/route_names.dart';
import '../providers/pets_provider.dart';
import '../widgets/pet_card_widget.dart';

class PetsPage extends ConsumerWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(myPetsProvider);
    final canAdd = ref.watch(canAddPetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: [
          if (canAdd)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push(RouteNames.addPet),
            ),
        ],
      ),
      body: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) {
            return _EmptyState(canAdd: canAdd);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return PetCardWidget(
                pet: pet,
                onTap: () => context.push(
                  '${RouteNames.petProfile.replaceAll(':petId', '')}${pet.id}',
                ),
                onEdit: () => context.push(
                  '${RouteNames.editPet.replaceAll(':petId', '')}${pet.id}',
                ),
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir pet'),
                      content: Text(
                          'Tem certeza que deseja excluir ${pet.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(petFormProvider.notifier).deletePet(pet.id);
                    ref.invalidate(myPetsProvider);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erro ao carregar pets: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myPetsProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool canAdd;
  const _EmptyState({required this.canAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum pet cadastrado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione seu primeiro pet para começar a encontrar parceiros!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (canAdd) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.addPet),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Pet'),
              ),
            ] else ...[
              const SizedBox(height: 32),
              Text(
                'Limite de ${AppConstants.maxPetsFree} pets no plano gratuito.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
