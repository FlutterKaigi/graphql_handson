import 'package:flutter/material.dart';
import 'package:graphql_handson/features.dart';
import 'package:graphql_handson/repositories/github_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTopPage extends StatelessWidget {
  const MyTopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<dynamic>(
        future: fetchRepositories(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Text('Loading');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error : ${snapshot.error}'));
              }

              if (snapshot.data == null) {
                return const Text('No issues');
              }

              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: CardItem(
                        title: (showRepository && !showIssue)
                            ? item['name']
                            : item['title'] ?? '',
                        message: (showRepository && !showIssue)
                            ? ''
                            : item['description'] ?? '',
                        url: item['url'] ?? '',
                        updatedAt: item['updatedAt'] ?? '',
                      ),
                    );
                  });
            // return Center(child: Text(snapshot.data.data.toString()));
          }
        },
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    required this.title,
    required this.message,
    required this.url,
    required this.updatedAt,
  });
  final String title;
  final String message;
  final String url;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        color: Colors.white70,
        child: InkWell(
          onTap: () async {
            await launchUrl(
              Uri.parse(url),
              webOnlyWindowName: '_blank',
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87),
                ),
                Text(
                  updatedAt,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
