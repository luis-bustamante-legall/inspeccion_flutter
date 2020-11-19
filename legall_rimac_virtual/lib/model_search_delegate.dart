import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/models.dart';
import 'blocs/blocs.dart';

class ModelSearchDelegate extends SearchDelegate<String> {
  final BrandBloc bloc;
  final String brandId;

  ModelSearchDelegate(this.bloc,this.brandId) {
    bloc.add(LoadBrand(brandId));
  }

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
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, BrandState state) {
        if (state is BrandEmpty) {
          return LinearProgressIndicator();
        }
        else if (state is BrandLoaded) {
          var lowerQuery = query.toLowerCase();
          var results = state.brandModel.models.where((model) =>
              model.toLowerCase().contains(lowerQuery))
              .toList();
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.navigate_next),
                title: Text(results[index]),
                onTap: () => close(context, results[index]),
              );
            },
            itemCount: results.length,
          );
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

    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, BrandState state) {
        if (state is BrandEmpty) {
          return LinearProgressIndicator();
        }
        else if (state is BrandLoaded) {
          var lowerQuery = query.toLowerCase();
          var results = state.brandModel.models.where((model) =>
              model.toLowerCase().contains(lowerQuery))
              .toList();
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.navigate_next),
                title: Text(results[index]),
                onTap: () => close(context, results[index]),
              );
            },
            itemCount: results.length,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
