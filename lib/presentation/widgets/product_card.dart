import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';

/// Tarjeta de producto con diseño profesional
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !product.isAvailable;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Card(
        elevation: 0,
        color: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          side: BorderSide(
            color: isDisabled ? AppTheme.textDisabled : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: isDisabled ? null : onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con ícono - Sin gradiente
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingLarge),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.borderColor, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 36,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  // Contenido
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del producto
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),

                          // Descripción
                          if (product.description != null &&
                              product.description!.isNotEmpty)
                            Expanded(
                              child: Text(
                                product.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          const Spacer(),

                          // Código de fórmula
                          if (product.formulaCode != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppTheme.spacingSmall),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingSmall,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                child: Text(
                                  product.formulaCode!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),

                          // Precio
                          Text(
                            CurrencyFormatter.format(product.salePrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Badge de "No disponible"
            if (isDisabled)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'No disponible',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
