import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/features.dart';
import 'package:graphql_handson/graphql/query.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTopPage extends StatelessWidget {
  const MyTopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Query(
      options: QueryOptions(
        document: gql(
            (showRepository && !showIssue) ? repositoriesQuery : issuesQuery),
        variables: const {
          //
        },
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        pollInterval: const Duration(seconds: 10),
      ),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return const Text('Loading');
        }

        List? items = (showRepository && !showIssue)
            ? (result.data?['viewer']?['repositories']?['nodes'])
            : (result.data?['viewer']?['repository']?['issues']?['nodes']);

        if (items == null) {
          return const Text('No issues');
        }

        return ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
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
      },
    ));
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