import 'dart:developer';

import 'package:flutter/material.dart';

class IssueInputPage extends StatefulWidget {
  const IssueInputPage({super.key});

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
        title: const Text('テストアプリ'),
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
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '入力してください',
                        border: InputBorder.none,
                      ),
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
                    child: TextField(
                      keyboardType: TextInputType.multiline, // 改行の可否
                      maxLines: 4, // 改行可能な行数
                      decoration: const InputDecoration(
                        hintText: '入力してください',
                        border: InputBorder.none,
                      ),
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
                        log('Press');
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  '保存',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
