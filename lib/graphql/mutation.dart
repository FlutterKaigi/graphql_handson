// Issue
const String issueMutation = """
  mutation {
    createIssue(input: {
      repositoryId: "R_kgDOHx6taw",
      title: "Create Test",
      body: "This is a body."
    }) {
      issue {
        id
      }
    }
  }
""";
