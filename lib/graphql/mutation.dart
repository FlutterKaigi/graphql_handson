// Issue
const String issueMutation = """
mutation createIssue {
  createIssue(input:{repositoryId:"R_kgDOHx6taw",title:"NuumA",body:"BodyTest"}) {
    issue {
      id
    }
  }
}
""";
