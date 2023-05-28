import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/auth.dart';
import 'package:flutter_firebase/forms/update_data.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  List<String> docIDs = [];
  List<String> filteredDocIDs = [];
  bool isAscending = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDocID();
  }

Future<void> getDocID() async {
  final query = FirebaseFirestore.instance.collection('users');

  final snapshot = await query.get();

  List<String> sortedDocIDs = snapshot.docs.map((document) => document.id).toList();

  if (!isAscending) {
    sortedDocIDs = sortedDocIDs.reversed.toList(); // Sort in descending order by ID
  }

  setState(() {
    docIDs = sortedDocIDs;
    filteredDocIDs = List.from(docIDs); // Initialize filtered list with all documents
  });
}



  Future<void> filterDocuments(String searchText) async {
    setState(() {
      if (searchText.isEmpty) {
        filteredDocIDs = List.from(docIDs); // If search text is empty, show all documents
      } else {
        filteredDocIDs = [];
        for (String docID in docIDs) {
          getEmailFromDocumentID(docID).then((email) {
            if (email.toLowerCase().contains(searchText.toLowerCase())) {
              setState(() {
                filteredDocIDs.add(docID);
              });
            }
          }).catchError((error) {
            print('Error retrieving email: $error');
          });
        }
      }
    });
  }

  Future<String> getEmailFromDocumentID(String docID) async {
    String email = '';
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(docID).get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            snapshot.data() as Map<String, dynamic>;
        email = data['email'] ?? '';
      }
    } catch (error) {
      print('Error retrieving email: $error');
    }
    return email;
  }

  Future<void> deleteDocument(String docID) async {
    await FirebaseFirestore.instance.collection('users').doc(docID).delete();
    setState(() {
      docIDs.remove(docID);
      filteredDocIDs.remove(docID);
    });
  }

  Future<void> updateDocument(String docID) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateDocumentPage(docID: docID),
      ),
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return Row(
      children: [
        const Text('Firebase Act 1 & 2 and Midterm'),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDocumentPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _userUid() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        user?.email ?? '',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
      ),
      onPressed: signOut,
      child: const Text('Log Out'),
    );
  }

  Widget _sortButton() {
    return IconButton(
      icon: isAscending ? Icon(Icons.arrow_upward) : Icon(Icons.arrow_downward),
      onPressed: () {
        setState(() {
          isAscending = !isAscending;
          getDocID();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        backgroundColor: Colors.blue,
        actions: [
          _sortButton(),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _userUid(),
            SizedBox(height: 16),
            _signOutButton(),
            TextField(
              controller: searchController,
              onChanged: (value) => filterDocuments(value),
              decoration: InputDecoration(
                labelText: 'Search by email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDocIDs.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<String>(
                    future: getEmailFromDocumentID(filteredDocIDs[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                        );
                      }

                      if (snapshot.hasError) {
                        return ListTile(
                          title: Text('Error retrieving email'),
                        );
                      }

                      String email = snapshot.data ?? '';

                      return ListTile(
                        title: Text(email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  updateDocument(filteredDocIDs[index]),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  deleteDocument(filteredDocIDs[index]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getEmailFromDocumentID(String docID) async {
  String email = '';
  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(docID).get();
    if (snapshot.exists) {
      Map<String, dynamic> data =
          snapshot.data() as Map<String, dynamic>;
      email = data['email'] ?? '';
    }
  } catch (error) {
    print('Error retrieving email: $error');
  }
  return email;
}

class AddDocumentPage extends StatefulWidget {
  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _passwordFieldController = TextEditingController();

  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _textFieldController.addListener(_checkInput);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _passwordFieldController.dispose();
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
        title: Text('Add User'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email'),
            TextField(
              controller: _textFieldController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Text('Password'),
            TextField(
              controller: _passwordFieldController,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _addUser,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addUser() async {
    try {
      String email = _textFieldController.text;
      String password = _passwordFieldController.text;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error adding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding user')),
      );
    }
  }
}

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
    getEmailFromDocumentID(widget.docID).then((email) {
      _textFieldController.text = email;
    });
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
        title: Text('Update User'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email'),
            TextField(
              controller: _textFieldController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _updateUser,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUser() async {
    try {
      String email = _textFieldController.text;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docID)
          .update({
        'email': email,
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error updating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user')),
      );
    }
  }
}
