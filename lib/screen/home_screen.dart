import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List data = [];
  int page = 0;
  int limit = 20;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  var scrollController = ScrollController();
  @override
  void initState() {
    getProduct();
    scrollController.addListener(loadMore);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isFirstLoadRunning
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                    controller: scrollController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(data[index]['title']),
                          subtitle: Text(data[index]['body']),
                        ),
                      );
                    },
                  )),
                  if (isLoadMoreRunning == true)
                    const Center(child: CircularProgressIndicator()),
                  if (hasNextPage == false)
                    const Center(
                      child: Text('You have fetched all the data'),
                    )
                ],
              ));
  }

  void getProduct() async {
    print('getProduct');
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      const url = 'https://jsonplaceholder.typicode.com/posts';
      http.Response response;
      response = await http.get(Uri.parse("$url?_page=$page&_limit=$limit"));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        print('data-$data');
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 1) {
      setState(() {
        isLoadMoreRunning = true;
      });
      page += 1;
      try {
        const url = 'https://jsonplaceholder.typicode.com/posts';
        http.Response response;
        response = await http.get(Uri.parse("$url?_page=$page&_limit=$limit"));

        final List fetcheddata = jsonDecode(response.body);
        print('fetcheddata-$fetcheddata');
        if (fetcheddata.isNotEmpty) {
          setState(() {
            data.addAll(fetcheddata);
          });
        } else {
          setState(() {
            hasNextPage = false;
          });
        }
      } catch (e) {
        print('error-$e');
      }
      setState(() {
        isLoadMoreRunning = false;
      });
    }
  }
}
