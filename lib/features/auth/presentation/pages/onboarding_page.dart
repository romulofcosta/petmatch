import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/services/geolocation_service.dart';
import '../../../../routes/route_names.dart';
import '../providers/auth_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Dados do perfil
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  DateTime? _birthDate;

  static const int _tutorialPages = 3;
  static const int _formPageIndex = 3;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      icon: Icons.pets,
      title: 'Bem-vindo ao PetMatch!',
      description:
          'Encontre o par perfeito para seu pet socializar ou encontrar um companheiro.',
      color: AppColors.primary,
    ),
    _OnboardingItem(
      icon: Icons.favorite,
      title: 'Curta e Conecte-se',
      description:
          'Deslize para curtir pets perto de você. Quando ambos curtirem, é match!',
      color: AppColors.secondary,
    ),
    _OnboardingItem(
      icon: Icons.chat_bubble,
      title: 'Converse e Marque um Encontro',
      description:
          'Após o match, converse com o tutor e marque um encontro para os pets.',
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage < _formPageIndex)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _pageController.animateToPage(
                    _formPageIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Pular', style: AppTextStyles.link),
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialPages + 1,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (index < _tutorialPages) {
                    return _buildTutorialPage(_items[index]);
                  }
                  return _buildProfileForm();
                },
              ),
            ),
            if (_currentPage < _tutorialPages) _buildPageIndicator(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                text: _currentPage < _tutorialPages
                    ? (_currentPage == _tutorialPages - 1
                        ? 'Começar'
                        : 'Próximo')
                    : 'Salvar e Continuar',
                onPressed: () {
                  if (_currentPage < _tutorialPages) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(_OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 64,
              color: item.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Complete seu perfil',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Precisamos de algumas informações para encontrar os melhores matches para seu pet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Seu nome',
            hint: 'Como você se chama',
            controller: _nameController,
            validator: Validators.name,
            prefixIcon: const Icon(Icons.person_outline),
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
            label: 'Cidade',
            hint: 'Ex: São Paulo',
            controller: _cityController,
            validator: Validators.required,
            prefixIcon: const Icon(Icons.location_city),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Estado',
            hint: 'Ex: SP',
            controller: _stateController,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Estado é obrigatório';
              if (v.trim().length != 2) return 'Use a sigla (2 letras)';
              return null;
            },
            prefixIcon: const Icon(Icons.map),
            maxLength: 2,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _tutorialPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _completeOnboarding() async {
    if (_nameController.text.trim().isEmpty) {
      _pageController.animateToPage(
        _formPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha seu nome')),
      );
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione sua data de nascimento')),
      );
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha sua cidade')),
      );
      return;
    }

    if (_stateController.text.trim().length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o estado com a sigla (2 letras)')),
      );
      return;
    }

    try {
      final repository = ref.read(authRepositoryProvider);
      final currentUser = repository.currentUser;
      if (currentUser == null) return;

      // Criação do perfil acontece exclusivamente pela Edge Function
      // `create-profile`, que valida idade/localização, calcula o geohash real
      // e registra o LGPD consent_logs. Nunca insere em `users` direto/RPC.
      final location =
          await const GeolocationService().getCurrentPosition();
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

      await repository.createProfile(
        uid: currentUser.uid,
        displayName: _nameController.text.trim(),
        birthDate: _birthDate!,
        latitude: location.latitude,
        longitude: location.longitude,
        city: _cityController.text.trim().toUpperCase(),
        state: _stateController.text.trim().toUpperCase(),
        consents: const {
          'terms_of_use': true,
          'privacy_policy': true,
        },
      );

      // Forçar reload do estado de auth
      ref.invalidate(authStateProvider);

      if (mounted) {
        context.go(RouteNames.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    }
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
