import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../provider/search_provider.dart';
import '../home_page.dart';

class MyRadioTile extends StatelessWidget {
  String title,query;
  MyRadioTile({super.key,required this.title,required this.query});

  @override
  Widget build(BuildContext context) {
    SearchProvider searchProviderFalse = Provider.of<SearchProvider>(context, listen: false);
    SearchProvider searchProviderTrue = Provider.of<SearchProvider>(context, listen: true);
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.white, // Unselected color
        // Set other theme properties if needed
      ),
      child: RadioListTile<String>(
        title: Text(title,style: TextStyle(color: Colors.white),),
        value: title,
        activeColor: Colors.white,
        groupValue: searchProviderTrue.selectedSearchEngine,
        onChanged: (value) {
          searchProviderFalse.changeSearchEngine(value!);
          searchProviderFalse.getSearchEngineUrl(query);
          refreshWeb(searchProviderTrue);
          Navigator.pop(context);
        },
      ),
    );
  }
}

Future<void>? refreshWeb(SearchProvider searchProviderTrue) {
  return webViewController?.loadUrl(
    urlRequest: URLRequest(
      url: WebUri(searchProviderTrue.setSearchEngine),
    ),
  );
}
