// Issueの追加
const String createMutation = '''
  mutation (\$titleText: String!, \$bodyText: String!) {
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

// Issueの更新
const String updateMutation = '''
  mutation (\$idText: String!, \$titleText: String!, \$bodyText: String!) {
    updateIssue(input: {
      repositoryId: "R_kgDOHx6taw",
      id: \$idText,
      title: \$titleText,
      body: \$bodyText
    }) {
      issue {
        id
      }
    }
  }
''';
