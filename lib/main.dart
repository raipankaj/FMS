import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyEntryWid());

class MyEntryWid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "My material app",
        home: new FeedbackTitle());
  }
}

class FeedbackTitle extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FeedbackState();
  }
}

class _FeedbackState extends State<FeedbackTitle> {
  final feedbackController = TextEditingController();
  final feedbackTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    feedbackController.dispose();
    feedbackTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("FMS", style: new TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: EdgeInsets.all(48.0),
          child: Form(
            key: formKey,
            child: new ListView(
              children: <Widget>[
                _FeedbackTitleWidget(feedbackController),
                Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: _FeedbackWidget(feedbackTextController)),
                Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child:
                    _SubmitButton(
                        feedbackController, feedbackTextController, formKey)
                )
              ],
            ),
          ),
        ));
  }
}

class _FeedbackTitleWidget extends StatelessWidget {
  final TextEditingController feedbackController;

  _FeedbackTitleWidget(this.feedbackController);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: "Subject"),
      controller: feedbackController,
      validator: (val) =>
      val.isEmpty ? "Please enter subject" : null,
    );
  }
}

class _FeedbackWidget extends StatelessWidget {

  final TextEditingController feedbackTextController;

  _FeedbackWidget(this.feedbackTextController);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: "Feedback"),
      keyboardType: TextInputType.multiline,
      maxLines: 10,
      controller: feedbackTextController,
      validator: (val) =>
      val.isEmpty ? "Please enter feedback" : null,
    );
  }
}

class _SubmitButton extends StatelessWidget {

  final TextEditingController _feedbackController;
  final TextEditingController _feedbackTextController;
  final GlobalKey<FormState> formKey;

  _SubmitButton(this._feedbackController, this._feedbackTextController,
      this.formKey);

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: EdgeInsets.only(top: 18.0),
        child: new RaisedButton(
            padding: EdgeInsets.all(12.0),
            color: Colors.blue,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            onPressed: () =>
                _onSubmitPress(
                    context, _feedbackController, _feedbackTextController,
                    formKey)
        ));
  }}

void _onSubmitPress(BuildContext context,
    TextEditingController feedbackController,
    TextEditingController feedbackTextController,
    GlobalKey<FormState> formKey) {
  var form = formKey.currentState;
  if (form.validate()) {
    form.save();

    Firestore.instance.collection("issues").add({
      'subject': feedbackController.text,
      'feedback': feedbackTextController.text
    }).whenComplete(() {
      print("Doc added");
      Scaffold.of(context).showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: const Text("Feedback sumbitted successfully")));
      feedbackController.clear();
      feedbackTextController.clear();
    }).catchError(
            (e) =>
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text(e.toString()),
              duration: new Duration(seconds: 6),
            )));
  }
}
