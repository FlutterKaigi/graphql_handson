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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テストアプリ'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
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
                color: const Color(0xFFEFEFEF),
                padding: const EdgeInsets.only(left: 21),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '入力してください',
                    border: InputBorder.none,
                  ),
                  onChanged: (titleValue) {
                    setState(() {
                      titleInputText = titleValue;
                    });
                    log('Title : $titleInputText');
                    log('Body : $bodyInputText');
                  },
                ),
              ),
              Container(
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
                color: const Color(0xFFEFEFEF),
                padding: const EdgeInsets.only(left: 21),
                child: TextField(
                  keyboardType: TextInputType.multiline, // 改行の可否
                  maxLines: 4, // 改行可能な行数
                  decoration: const InputDecoration(
                    hintText: '入力してください',
                    border: InputBorder.none,
                  ),
                  onChanged: (bodyValue) {
                    setState(() {
                      bodyInputText = bodyValue;
                    });
                    log('Title : $titleInputText');
                    log('Body : $bodyInputText');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
