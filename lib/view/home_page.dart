import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../provider/search_provider.dart';
import 'components/my_radio_tile.dart';

InAppWebViewController? webViewController;
TextEditingController txtSearch = TextEditingController();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double height = MediaQuery.of(context).size.height;
    SearchProvider searchProviderFalse =
    Provider.of<SearchProvider>(context, listen: false);
    SearchProvider searchProviderTrue =
    Provider.of<SearchProvider>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow layout adjustment when keyboard appears
      backgroundColor: Color(0xff202124),
      appBar: AppBar(toolbarHeight: 20,),
      body: Column(
        children: [
          if (searchProviderTrue.isLoading)
            const LinearProgressIndicator(),
          SizedBox(height:10 ,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 00),
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(searchProviderTrue.setSearchEngine)),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  searchProviderFalse.updateLoadingStatus(true);
                },
                onLoadStop: (controller, url) {
                  searchProviderFalse.updateLoadingStatus(false);
                  String query = txtSearch.text != ""
                      ? txtSearch.text
                      : searchProviderTrue.selectedSearchEngine;
                  searchProviderFalse.addToHistory(url.toString(), query);
                },
              ),
            ),
          ),
          Container(
            color: Color(0xff171717),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: txtSearch,
                style: TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    searchProviderFalse.getSearchEngineUrl(value);
                    refreshWeb(searchProviderTrue);
                  }
                },
                decoration: buildInputDecoration(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Color(0xff171717),
        height: height * 0.079,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  searchProviderFalse.getSearchEngineUrl("");
                  txtSearch.clear();
                  refreshWeb(searchProviderTrue);
                },
                icon: const Icon(Icons.home,color: Colors.white,)),
            IconButton(
                onPressed: () async {
                  if (await webViewController?.canGoBack() ?? false) {
                    webViewController?.goBack();
                  }
                },
                icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
            IconButton(
              onPressed: () {
                refreshWeb(searchProviderTrue);
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
            IconButton(
                onPressed: () async {
                  if (await webViewController?.canGoForward() ?? false) {
                    webViewController?.goForward(); // Go forward in web view
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios,color: Colors.white,)),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  buildPopupMenuItem(width, "History", 0),
                  buildPopupMenuItem(width, "Search Engine", 1)
                ];
              },
              onSelected: (item) async {
                if (item == 1) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String query = txtSearch.text;
                      return AlertDialog(
                        backgroundColor: Color(0xff202124),
                        title: const Text("Search Engine",style: TextStyle(color: Colors.white),),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyRadioTile(title: "Google", query: query),
                            MyRadioTile(title: "Yahoo", query: query),
                            MyRadioTile(title: "bing", query: query),
                            MyRadioTile(title: "Duck Duck Go", query: query),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  modalBottomSheet(context);
                }
              },
            ),
            
          ],
        ),
      ),
    );

  }
}

PopupMenuItem<int> buildPopupMenuItem(double width, String title, int value) {
  return PopupMenuItem<int>(
    value: value,
    child: Text(title, style: TextStyle(fontSize: width * 0.042)),
  );
}

InputDecoration buildInputDecoration() {
  return InputDecoration(

    filled: true,
    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 22),
    fillColor: Color(0xff171717),
  // Softer background for input field
    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 1), // Light border for focus
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1), // Subtle border for normal state
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1), // For error state
    ),
    hintText: "Search here...",
    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
  );
}

void modalBottomSheet(BuildContext context) {
  // Ensure SearchProvider is available
  SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (BuildContext context, ScrollController scrollController) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xff171717),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 5.0, right: 5, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () {
                          Navigator.pop(context);

                        }, icon: Icon(Icons.close,color: Colors.white,)),
                        Text('History',
                          style: TextStyle(
                              fontFamily: 'f1'
                              ,letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              fontSize: 25,
                              color: Colors.white),),
                        IconButton(onPressed: () {
                          Navigator.pop(context);
                        }, icon: Icon(Icons.done,color: Colors.white,)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<SearchProvider>(
                      builder: (BuildContext context, searchProviderTrue, Widget? child) {
                        // Check if userHistory is empty
                        if (searchProviderTrue.userHistory.isEmpty) {
                          return const Center(
                            child: Text("No history available",style: TextStyle(color: Colors.white,),),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController, // Ensure scrollController is set
                          itemCount: searchProviderTrue.userHistory.length,
                          itemBuilder: (context, index) {
                            final data = searchProviderTrue.userHistory[index];
                            final url = data.split('---').sublist(0, 1).join(' ');
                            final search = data.split('---').sublist(1, 2).join(' ');
                            return ListTile(
                              onTap: () {
                                txtSearch.text = search;
                                webViewController?.loadUrl(
                                  urlRequest: URLRequest(url: WebUri(url)),
                                );
                                Navigator.pop(context);
                              },
                              leading: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(CupertinoIcons.link,color: Colors.white,),
                              ),
                              title: Text(search,style: TextStyle(color: Colors.white,),),
                              subtitle: Text(url,style: TextStyle(color: Colors.white,),maxLines: 1,softWrap: true,overflow: TextOverflow.ellipsis,),
                              trailing: IconButton(
                                onPressed: () {
                                  searchProvider.deleteFromHistory(index);
                                },
                                icon: const Icon(Icons.delete,color: Colors.white,),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



