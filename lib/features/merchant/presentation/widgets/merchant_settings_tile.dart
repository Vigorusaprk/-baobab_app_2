import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// La section « Commerce » des paramètres.
///
/// Elle dit trois choses différentes selon la situation : ouvrez votre
/// espace, votre demande est en cours, ou vendez sur Baobabe. Un seul
/// libellé pour les trois cas laisserait l'utilisateur cliquer sans savoir
/// ce qui l'attend.
class MerchantSettingsSection extends StatelessWidget {
  final bool isLoggedIn;

  const MerchantSettingsSection({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        // Tant qu'on ne sait pas, on n'affiche rien : proposer d'ouvrir un
        // commerce à quelqu'un qui en a déjà un serait pire que d'attendre.
        if (state is MerchantUnknown || state is MerchantLoading) {
          return const SizedBox.shrink();
        }

        if (state is MerchantReady) {
          return DetailSection(
            sectionTitle: 'Commerce',
            children: [
              InfoTile(
                subtitle: 'Mon espace commerçant',
                icon: Icons.storefront_outlined,
                onTap: () => context.goNamed('merchant'),
                trailing: _PendingBadge(
                  count:
                      state.space.stats.pendingOrders +
                      state.space.stats.pendingReservations,
                ),
              ),
            ],
          );
        }

        final application = state is NotAMerchant ? state.application : null;
        final isPending =
            application != null &&
            application.status == ApplicationStatus.pending;

        return DetailSection(
          sectionTitle: 'Commerce',
          children: [
            InfoTile(
              subtitle: isPending
                  ? 'Demande en cours d\'examen'
                  : 'Devenir commerçant',
              icon: isPending
                  ? Icons.hourglass_empty
                  : Icons.add_business_outlined,
              onTap: () {
                if (!isLoggedIn) {
                  showAuthRequiredCard(
                    context,
                    message:
                        'Connectez-vous pour ouvrir votre commerce sur Baobabe.',
                  );
                  return;
                }
                if (isPending) return;
                context.pushNamed('becomeMerchant');
              },
              trailing: isPending
                  ? Text(
                      application.businessName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}

/// Nombre de demandes en attente, pour que le commerçant sache qu'on
/// l'attend sans avoir à ouvrir son espace.
class _PendingBadge extends StatelessWidget {
  final int count;

  const _PendingBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.errorContent,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
