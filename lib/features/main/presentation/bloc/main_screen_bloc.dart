import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_scree_event.dart';

//Le BLoC gere l'index de l'onglet actif
class MainScreenBloc extends Bloc<MainScreenEvent, int>{
  MainScreenBloc() :super(0){
    on<TabChangeEvent>((event, emit){
      emit(event.index);
    });
  }
}