import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data-layer/models/mars_photo.dart';
import '../../data-layer/repo/repo.dart';

part 'mars_state.dart';

class MarsCubit extends Cubit<MarsState> {
  final Repo repo;

  MarsCubit({required this.repo}) : super(MarsInitial()) {
    fetchRoverData();
  }

  static MarsCubit get(context) => BlocProvider.of<MarsCubit>(context);

  Future<void> fetchRoverData() async {
    emit(RoverDataLoading());
    await repo.fetchCuriosityData();
    emit(RoverDataLoaded());
  }


  int pageCount = 1;

  final ScrollController scrollController = ScrollController();

  void checkScrollPosition(DateTime earthDate) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchMarsPhotos(earthDate, page: pageCount++);
    }
  }

  var isPhotosLoaded = false;
  List<MarsPhoto> photosList = [];

  void resetHomePage() {
    photosList = [];
    isPhotosLoaded = true;
  }

  void fetchMarsPhotos(DateTime? earthDate, {int? page}) async {
    emit(MarsPhotosLoading());
    final lPhoto = earthDate != null
        ? await repo.fetchDatePhotos(earthDate, page: page ?? pageCount)
        : await repo.fetchLatestPhotos();
    photosList.addAll(lPhoto);
    isPhotosLoaded = true;
    emit(MarsPhotosLoaded());
  }
}
