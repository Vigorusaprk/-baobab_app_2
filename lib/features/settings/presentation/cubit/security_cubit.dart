import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

/// État de la sécurité du compte : un mot de passe est-il posé, et la
/// dernière lecture aboutie ou non. Partagé entre l'écran des paramètres
/// (le libellé de l'entrée) et la page « Sécurité » (son titre et son
/// résultat).
class SecurityState extends Equatable {
  const SecurityState({this.hasPassword = false, this.isLoading = true});

  final bool hasPassword;
  final bool isLoading;

  SecurityState copyWith({bool? hasPassword, bool? isLoading}) =>
      SecurityState(
        hasPassword: hasPassword ?? this.hasPassword,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [hasPassword, isLoading];
}

class SecurityCubit extends Cubit<SecurityState> {
  SecurityCubit({required this.authRepository})
    // Une erreur n'affiche pas de « faux » côté utilisateur : on démarre
    // en chargement, et `load` tranche.
    : super(const SecurityState());

  final AuthRepository authRepository;

  /// Relit la convention `password_set` du profil Supabase.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final hasPassword = await authRepository.hasPassword();
      emit(SecurityState(hasPassword: hasPassword, isLoading: false));
    } catch (_) {
      // On garde la dernière valeur connue : mieux vaut un libellé « Définir »
      // que de bloquer la page sur une erreur réseau silencieuse.
      emit(state.copyWith(isLoading: false));
    }
  }
}
