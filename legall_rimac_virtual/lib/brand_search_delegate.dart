import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/models.dart';
import 'blocs/blocs.dart';

class BrandSearchDelegate extends SearchDelegate<BrandModel> {
  final BrandBloc bloc;

  BrandSearchDelegate(this.bloc);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        query = "";
      },
    )
  ];

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: BackButtonIcon(),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    bloc.add(SearchBrands(query));
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, BrandState state) {
        if (state is BrandEmpty) {
          return LinearProgressIndicator();
        }
        else if (state is BrandSearching) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else if (state is BrandResults) {
          if (!state.success) {
            print(state.errorMessage);
            return Container(
              child: Text('Error'),
            );
          } else {
            return ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.directions_car),
                  title: Text(state.brands[index].brandName),
                  onTap: () => close(context, state.brands[index]),
                );
              },
              itemCount: state.brands.length,
            );
          }
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty)
      return Container();

    bloc.add(SearchBrands(query.toLowerCase()));
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, BrandState state) {
        if (state is BrandEmpty) {
          return LinearProgressIndicator();
        }
        else if (state is BrandSearching) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else if (state is BrandResults) {
          if (!state.success) {
            print(state.errorMessage);
            return Container(
              child: Text('Error'),
            );
          } else {
            return ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.directions_car),
                  title: Text(state.brands[index].brandName),
                  onTap: () => close(context, state.brands[index]),
                );
              },
              itemCount: state.brands.length,
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}
