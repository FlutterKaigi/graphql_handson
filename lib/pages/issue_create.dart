import 'package:flutter/material.dart';
import 'package:graphql_handson/repositories/github_repository.dart';

class IssueInputPage extends StatefulWidget {
  const IssueInputPage({super.key, this.id, this.title, this.body});

  final String? id;
  final String? title;
  final String? body;

  @override
  State<IssueInputPage> createState() => _IssueInputState();
}

class _IssueInputState extends State<IssueInputPage> {
  String titleInputText = '';
  String bodyInputText = '';
  bool _isEnabled = false;

  void _changeEnabled() {
    if (titleInputText.isNotEmpty && bodyInputText.isNotEmpty) {
      _isEnabled = true;
    } else {
      _isEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.id == null
            ? const Text('Issue Create')
            : const Text('Issue Update'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFEFEFEF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                      left: 21,
                      top: 10,
                      bottom: 10,
                    ),
                    child: const Text(
                      'title',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 21),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: '入力してください',
                        border: InputBorder.none,
                      ),
                      initialValue: widget.title ?? titleInputText,
                      onChanged: (titleValue) {
                        titleInputText = titleValue;
                        setState(() {
                          _changeEnabled();
                        });
                      },
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                        left: 21,
                        top: 10,
                        bottom: 10,
                      ),
                      child: const Text(
                        'body',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(left: 21),
                    child: TextFormField(
                      keyboardType: TextInputType.multiline, // 改行の可否
                      maxLines: 4, // 改行可能な行数
                      decoration: const InputDecoration(
                        hintText: '入力してください',
                        border: InputBorder.none,
                      ),
                      initialValue: widget.body ?? bodyInputText,
                      onChanged: (bodyValue) {
                        bodyInputText = bodyValue;
                        setState(() {
                          _changeEnabled();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 21),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: !_isEnabled
                    ? null
                    : () {
                        if (widget.id == null) {
                          createIssue(
                            title: titleInputText,
                            body: bodyInputText,
                          );
                        } else {
                          updateIssue(
                            id: widget.id ?? '',
                            title: titleInputText,
                            body: bodyInputText,
                          );
                        }
                        Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  widget.id == null ? '保存' : '更新',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
