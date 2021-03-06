import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'detail.dart';
import 'updateUser.dart';
import 'dart:async';
final FirebaseAuth _auth = FirebaseAuth.instance;

String defimg =
    "https://firebasestorage.googleapis.com/v0/b/final-4575e.appspot.com/o/logo.png?alt=media&token=8be50df6-ef03-4c85-90e6-856ea9d6cb5e";
var formatter = new DateFormat('yyyy-MM-dd(EEE)');
var formatterHour = DateFormat('yyyy-MM-dd(EEE) hh:mm');
List<dynamic> stime = null;
class MyPage extends StatefulWidget {
  final FirebaseUser user;

  DocumentSnapshot document;

  MyPage({Key key,
    @required this.document,
    @required this.user,
  });

  @override
  _MyPageState createState() {
    return _MyPageState(
      user: user,
    );
  }
}

class _MyPageState extends State<MyPage> {
  DocumentSnapshot document;
  FirebaseUser user;

  _MyPageState({
    Key key,
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
//        title: Text("asd"),
        backgroundColor: Color.fromARGB(255, 25, 14, 78),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 20, 8.0, 10),
        child: ListView(
          children: <Widget>[
            Center(
                child: Text("마이 페이지",
                    style: TextStyle(fontSize: 25, color: Colors.white))),
            _UserInfoSection(user:user)
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 25, 14, 78),
    );
  }
}

class _UserInfoSection extends StatefulWidget {

  final FirebaseUser user;
  DocumentSnapshot document;

  _UserInfoSection({Key key, @required this.document, @required this.user});

  @override
  _UserInfoSectionState createState(){
    return _UserInfoSectionState(user: user,);
  }
}

class _UserInfoSectionState extends State<_UserInfoSection> {

  final FirebaseUser user;

  List<Item> _data = generateItems(3);
  DocumentSnapshot document;
  double _bodyHeight = 0.0;
  String _selectedCategory = '물건'; // = '물건';
  String _selectedSubCategory = '공구'; // = '공구';
//  String imageUrl="";
  String imageUrl = defimg;
  String phoneN = "";
  String myName = "";
  String userUID;
  bool isAnonymous = true;
  bool getOnce = false;

  _UserInfoSectionState({
    Key key,
    @required this.user,
  });

  void getUSer() async {
    getOnce = true;
    final FirebaseUser user = await _auth.currentUser();

    setState(() {
      user.displayName == null ? myName = "익명" : myName = user.displayName;
      userUID = user.uid;
      user.photoUrl == null ? imageUrl = defimg : imageUrl = user.photoUrl;
      isAnonymous = user.isAnonymous;
      phoneN = user.phoneNumber;
    });

//    print(imageUrl);
//    print(myName);
//    print(user.uid);
//    print(isAnonymous);
  }

  Widget build(BuildContext context) {
    if (!getOnce) getUSer();

    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.fromLTRB(16.0, 50, 16.0, 10),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(10.0),
        color: Color.fromARGB(50, 0, 0, 0),
      ),
      child: Form(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    children: [
                  Image.network(imageUrl, width: 100.0, height: 100.0),
                  SizedBox(width: 30),
                  Column(
                    children:[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0,20,10,0),
                    child: Text(myName,
                        style: TextStyle(fontSize: 20.0, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(80,8,0,0),
                    child: MaterialButton(
                        minWidth: 10,
                        height: 30,
                        child: Text('정보수정', style: TextStyle(color: Colors.white, fontSize: 11)),
                        color: Color.fromARGB(50, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new UpdateUserPage(
                                      user: user)));
                        }),
                  ),
                ]
                  )
                ]),

                SizedBox(height: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[],
                ),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    print(index.toString() + ", " + isExpanded.toString());
                    setState(() {
                      _data[index].isExpanded = !isExpanded;
                      if (_data[0].isExpanded) {
                        _data[0].isExpanded = !_data[0].isExpanded;
                        _data[1].isExpanded = false;
                        _data[2].isExpanded = false;
                        if (!_data[0].isExpanded)
                          _data[0].isExpanded = !_data[0].isExpanded;
                      } else if (_data[1].isExpanded) {
                        _data[0].isExpanded = false;
                        _data[1].isExpanded = !_data[1].isExpanded;
                        _data[2].isExpanded = false;
                        if (!_data[1].isExpanded)
                          _data[1].isExpanded = !_data[1].isExpanded;
                      } else if (_data[2].isExpanded) {
                        _data[0].isExpanded = false;
                        _data[1].isExpanded = false;
                        _data[2].isExpanded = true;
                        if (!_data[2].isExpanded)
                          _data[2].isExpanded = !_data[2].isExpanded;
                      }
                      else
                        _data[index].isExpanded = !isExpanded;
                    });
                  },
                  children: _data.map<ExpansionPanel>((Item item) {
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                            decoration:
                                new BoxDecoration(color: Colors.orangeAccent),
                            child: new ListTile(
                                title: Text(item.headerValue,
                                    style: TextStyle(color: Colors.white))));
                      },
                      body: Container(
                        child: ListTile(
//                          title: Text(item.expandedValue),
                          subtitle: StreamBuilder<QuerySnapshot>(
                              stream:
                                  item.expandedValue == 0
                                    ? Firestore.instance
                                    .collection('Transactions')
                                    .where('buyer', isEqualTo: userUID)
                                    .snapshots()
                                  : item.expandedValue == 1
                                      ? Firestore.instance
                                          .collection('Items')
                                          .where('seller', isEqualTo: userUID)
                                          .snapshots()
                                      : Firestore.instance
                                          .collection('Items')
                                          .where('likedUser',
                                              arrayContains: userUID)
                                          .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return LinearProgressIndicator();
                                if (snapshot.data.documents.length == 0)
                                  return Text("찾으시는 검색결과가 없넹~",
                                      style: TextStyle(color: Colors.white));
                                return Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      GridView.count(
                                        crossAxisCount: 4,
                                        shrinkWrap: true,
                                        childAspectRatio: 2 / 3,
                                        physics: ScrollPhysics(), // 스크롤 가능하게 해줌
                                        children: snapshot.data.documents
                                            .map((data) => _buildListItem(
                                                context,
                                                data,
                                                item.expandedValue))
                                            .toList(),
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                      isExpanded: item.isExpanded,
                      canTapOnHeader: true,
                    );
                  }).toList(),
                ),
              ]),
        ),
      ),
    );
  }

   Widget _buildListItem(BuildContext context, DocumentSnapshot document, int index) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: 60,
              height: 50,
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(),
                child: Ink.image(
                  image: index == 0?
                  NetworkImage(document['imageUrl']):
                  NetworkImage(document['imageUrl'][0]),
                  fit: BoxFit.cover,
                  child: InkWell(
                    onTap: () {
                      index == 0?
                      _showalert(document):
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(document: document, user: user)));
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.all(8.0),
              child: Text(document['name'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 10))),
        ]);
  }
  void _showalert(DocumentSnapshot document){
    final f = new DateFormat('yyyy-MM-dd hh:mm');
    AlertDialog dialog = AlertDialog(
        content: Container(
            width:250.0,
            height:300.0,
            child:Column(
                children:[
                  Container(
//                    color: Colors.orangeAccent,
                    width:250.0,
                    height:100.0,
                    child:Text("내가 대여한 물품",style:TextStyle(fontSize: 20.0)),
                    alignment: Alignment.center,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        SizedBox(width:10.0),
                        Text("물품명: " + document['name']),
                      ]
                  ),
                  SizedBox(height:15.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        SizedBox(width:10.0),
//                        Text("가격: " + document['price'] + "원"),
                      ]
                  ),
                  SizedBox(height:15.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        SizedBox(width:10.0),
//                        Text("거래장소: " + document['location']),
                      ]
                  ),
                  SizedBox(height:15.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Icon(Icons.calendar_today),
                        SizedBox(width:10.0),
                        Column(
                            children:[
                              Text("대여시작",style:TextStyle(fontSize: 12.0)),
                              Text("대여종료",style:TextStyle(fontSize: 12.0)),
                            ]
                        ),
                        SizedBox(width:10.0),
                        Column(
                            children:[

//                        Text(f.format(new DateTime.fromMillisecondsSinceEpoch(document['rentStart'])))

                              Text('${formatter.format((document['rentStart']).toDate())}'),
                              Text('${formatter.format((document['rentEnd']).toDate())}',style :TextStyle(color:Colors.red))
                            ]
                        )
                      ]
                  ),

                  SizedBox(height:10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlatButton(
                        child: Text("대여종료",style:TextStyle(color:Colors.white,fontSize: 15.0)),
                        color: Colors.orangeAccent,
                        onPressed: (){
                          deleteItem(document.documentID);
                          getOnce = true;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ]
            )
        ),
        actions: <Widget>[

        ]
    );
    showDialog(context:context,
        child:dialog);
  }
}

DateTime Date(document) {
}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  int expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return
      index == 0?
        Item(
          headerValue: '대여중인 상품',
          expandedValue: 0,
        )
        : index == 1
            ? Item(
                headerValue: '내 상품',
                expandedValue: 1,
              )
            : Item(headerValue: '찜한상품', expandedValue: 2);
  });
}

void deleteItem(id) {
  DocumentReference docR = Firestore.instance.collection('Transactions').document(id);

  docR.delete();
}