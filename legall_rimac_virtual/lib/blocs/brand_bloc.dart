import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class BrandBloc
    extends Bloc<BrandEvent, BrandState> {
  final BrandsRepository _brandsRepository;

  BrandBloc({@required BrandsRepository repository})
      : assert(repository != null),
        _brandsRepository = repository;

  @override
  BrandState get initialState => BrandEmpty();

  @override
  Stream<BrandState> mapEventToState(
      BrandEvent event) async* {
    if (event is SearchBrands) {
      yield* _searchBrands(event._searchTerm);
    } else if (event is ResultBrands) {
      yield* _resultBrands(event._results);
    } else if (event is LoadBrand) {
      yield* _loadBrand(event);
    }
  }

  Stream<BrandState> _loadBrand(LoadBrand event) async*{
    var brand = await _brandsRepository.get(event.brandId);
    yield BrandLoaded(brand);
  }

  Stream<BrandState> _searchBrands(String searchTerm) async* {
    try {
      add(ResultBrands(await _brandsRepository.search(searchTerm)));
    } catch (e, stackTrace) {
      yield BrandResults.withError(e.toString(), stackTrace: stackTrace);
    }
  }

  Stream<BrandState> _resultBrands(
      final List<BrandModel> brands) async* {
    yield BrandResults.successfully(brands);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

abstract class BrandEvent extends Equatable {
  const BrandEvent();

  @override
  List<Object> get props => [];
}

class SearchBrands extends BrandEvent {
  final String _searchTerm;

  const SearchBrands(
      this._searchTerm);
}

class LoadBrand extends BrandEvent {
  final String brandId;

  const LoadBrand(
      this.brandId);
}

class ResultBrands extends BrandEvent {
  final List<BrandModel> _results;

  const ResultBrands(this._results);

  @override
  List<Object> get props => [_results];
}

abstract class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object> get props => [];
}

class BrandEmpty extends BrandState {}

class BrandSearching extends BrandState {}

class BrandLoaded extends BrandState {
  final BrandModel brandModel;

  const BrandLoaded(this.brandModel);
  @override
  List<Object> get props => [brandModel];
}

class BrandResults extends BrandState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final List<BrandModel> brands;


  BrandResults(this.success, this.brands, this.errorMessage, this.stackTrace);

  factory BrandResults.successfully(
      List<BrandModel> brands) {
    assert(brands != null);
    return BrandResults(true, brands, null, null);
  }

  factory BrandResults.withError(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return BrandResults(false, null, errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [brands];
}