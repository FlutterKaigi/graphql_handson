// Issue
const String issueMutation = '''
  mutation (\$titleText: String!,\$bodyText: String!){
    createIssue(input: {
      repositoryId: "R_kgDOHx6taw",
      title: \$titleText,
      body: \$bodyText
    }) {
      issue {
        id
      }
    }
  }
''';
