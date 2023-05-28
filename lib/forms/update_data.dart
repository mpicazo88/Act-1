import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class UpdateDocumentPage extends StatefulWidget {
  final String docID;

  UpdateDocumentPage({required this.docID});

  @override
  _UpdateDocumentPageState createState() => _UpdateDocumentPageState();
}

class _UpdateDocumentPageState extends State<UpdateDocumentPage> {
  TextEditingController _textFieldController = TextEditingController();
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _textFieldController.addListener(_checkInput);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _checkInput() {
    String inputValue = _textFieldController.text;
    bool isValidEmail = EmailValidator.validate(inputValue);

    setState(() {
      _isButtonDisabled = inputValue.isEmpty || !isValidEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Document'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textFieldController,
              decoration: InputDecoration(
                labelText: 'New Email',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : updateDocument,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateDocument() async {
    try {
      String newValue = _textFieldController.text;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docID)
          .update({'email': newValue});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Document updated successfully'),
        ),
      );

      Navigator.pop(context); // Navigate back to the previous screen
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update document'),
        ),
      );
    }
  }
}
