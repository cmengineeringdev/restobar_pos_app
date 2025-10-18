import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/injection/injection_container.dart';
import '../../../domain/usecases/login_user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_page.dart';
import '../point_of_sale/select_point_of_sale_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final InjectionContainer _container = InjectionContainer();
  late final LoginUser _loginUser;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loginUser = _container.loginUser;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _loginUser(
        _usernameController.text.trim(),
        _passwordController.text,
        _companyCodeController.text.trim(),
      );

      if (mounted) {
        // Check if point of sale is already selected
        final selectedPos = await _container.getSelectedPointOfSale();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido, ${user.fullName}'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
        );

        // Navigate based on point of sale selection
        if (selectedPos == null) {
          // No point of sale selected -> go to selection screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const SelectPointOfSalePage()),
          );
        } else {
          // Point of sale already selected -> go to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? AppTheme.spacingXLarge
                      : AppTheme.spacingMedium,
                  vertical: AppTheme.spacingMedium,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - (AppTheme.spacingMedium * 2),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Panel izquierdo - Solo visible en desktop
                        if (isDesktop) ...[
                          Expanded(
                            child: _buildLeftPanel(),
                          ),
                          const SizedBox(width: AppTheme.spacingLarge),
                        ],

                        // Panel derecho - Formulario
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: _buildLoginForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColorDark, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.borderColorDark, width: 1),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 28,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Título
          const Text(
            'Sistema de Punto de Venta',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),

          // Descripción
          Text(
            'Gestiona tu negocio de manera eficiente y profesional con nuestra plataforma integral para restaurantes y bares.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Características
          _buildFeatureItem(Icons.inventory_2, 'Control de inventario'),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildFeatureItem(Icons.point_of_sale, 'Ventas rápidas'),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildFeatureItem(Icons.analytics, 'Reportes detallados'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        side: const BorderSide(color: AppTheme.borderColor, width: 1),
      ),
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      // Logo pequeño para móvil
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                          border: Border.all(
                              color: AppTheme.borderColor, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 24,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Subtítulo
                      const Text(
                        'Inicie sesión para continuar',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // Username Field
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Usuario',
                    hint: 'Ingrese su usuario',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // Company Code Field
                  CustomTextField(
                    controller: _companyCodeController,
                    label: 'Código de Empresa',
                    hint: 'Ejemplo: chikos_pizza',
                    prefixIcon: Icons.business_outlined,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el código de empresa';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función próximamente disponible'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSmall,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        '¿Olvidó su contraseña?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // Login Button
                  CustomButton(
                    text: 'Iniciar Sesión',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    icon: Icons.login,
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
