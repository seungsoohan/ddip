import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final replyController =  TextEditingController();



class DetailPage extends StatefulWidget {
  FirebaseUser user;
  DocumentSnapshot document;
  DetailPage ({Key key, @required this.document, @required this.user});
  @override
  _DetailPageState createState() => new _DetailPageState(document:document,user:user);
}

class _DetailPageState extends State<DetailPage> {
  DocumentSnapshot document;
  FirebaseUser user;
  var formatter = new DateFormat('yyyy-MM-dd(EEE)');
  var formatterHour = DateFormat('yyyy-MM-dd(EEE) hh:mm');
  DateTime _date = new DateTime.now();
  DateTime _date2 = new DateTime.now();
  List<dynamic> stime = null;
  List<dynamic> etime = null;

  bool isFirst = false;
  int likedCnt = null;
  bool _likedPressed = false;
  
  var myUid = null;
//  DateTime _date = new DateTime.now();
//  DateTime _date2 = new DateTime.now();
  _DetailPageState({Key key, @required this.document, @required this.user});




  void uploadTransaction() async {
    DocumentReference docTransR = Firestore.instance.collection('Transactions').document();
    DocumentReference docItemsR = Firestore.instance.collection('Items').document(document.documentID);
    DocumentReference docUserR = Firestore.instance.collection('Users').document();

    final FirebaseUser user = await _auth.currentUser();
//    print(document.documentID);
//    print(_date);
//    print(_date2);

    docTransR.setData({
      'buyer': user.uid,
//      'seller': 'b', // document의 owner 참조해서 추가하기
      'seller': document['seller'],
      'item': document.documentID,
      'date': DateTime.now(),
      'rentStart': _date,
      'rentEnd': _date2,
      'imageUrl': document['imageUrl'][0],
      'name': document['name']

    }
    );

    var buyers = List<dynamic>.from(document['buyer']);
    buyers.add(user.uid);

    docItemsR.updateData({
      'available': false,
      'buyer': buyers

    }
    );



    print(user);
  }

  void uploadReply () async {
    final FirebaseUser user = await _auth.currentUser();
    DocumentReference docItemsR = Firestore.instance.collection('Items').document(document.documentID);


    docItemsR.updateData({
      'reply': FieldValue.arrayUnion([
          {
            'name': user.displayName,
            'date': DateTime.now(),
            'content': replyController.text
          }
        ])


    }
    );
    replyController.clear();
  }

  void checkLiked() async{
    isFirst = true;
    final FirebaseUser user = await _auth.currentUser();
    final String uid = user.uid;
//      final String uid = "asd";
//    DocumentReference docItemsR = Firestore.instance.collection('Items').document(document.documentID);

    print(uid);

    var likedUser = List<dynamic>.from(document['likedUser']);
    likedCnt = document['like'];

    if(likedUser.contains(uid)){
      print("already!");
      setState(() {
        _likedPressed = true;
      });
    }
    else{
      print("not used");
      setState(() {
        _likedPressed = false;
      });

    }
  }



  void getUid() async {
    final FirebaseUser user = await _auth.currentUser();
    final String uid = user.uid;
    myUid = uid;
  }




  @override
  Widget build(BuildContext context) {

    if(document['reply'] == null) document.data['reply']={};
    DocumentReference docItemsR = Firestore.instance.collection('Items').document(document.documentID);

    if(!isFirst) checkLiked();
//    getUid();

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 25, 14, 78),
        title: Text("< "+document['category']+" > "+document['name']),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                _likedPressed ? Icons.favorite : Icons.favorite_border,
              color: _likedPressed ? Colors.red : Colors.white
            ),
            onPressed: ()  async {
              final FirebaseUser user = await _auth.currentUser();
              final String uid = user.uid;
//              final int liked = document['like'];
              if(likedCnt == null) likedCnt = document['like'];


              var likedUser = List<dynamic>.from(document['likedUser']);
//              if(likedUser.contains(uid)){
                if(_likedPressed){
                  likedCnt--;
                docItemsR.updateData({'like': likedCnt});
                likedUser.remove(uid);
                docItemsR.updateData({'likedUser': likedUser});
                setState(() {
                  _likedPressed = false;
                });
//                _showBar('You can only do it once!!');

              }
              else{
                likedCnt++;
                docItemsR.updateData({'like': likedCnt});
                likedUser.add(uid);
                docItemsR.updateData({'likedUser': likedUser});
                setState(() {
                  _likedPressed = true;
                });

//                _showBar('I like it');
              }


            },
          )
        ],
      ),
      backgroundColor: Color.fromARGB(255, 25, 14, 78),
      body:
      _buildBody(context),
//      Padding(
//        padding: const EdgeInsets.all(15.0),
//        child: ListView(
//          children: <Widget>[
//            _ActionButtonSection(),
//            _ReplyListSection(),
//            _RelatedItemSection(),
//          ],
//        ),
//      ),
    );
  }
  Widget _buildBody(BuildContext context) {



    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Items').where('name',isEqualTo: document['name']).snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    if(snapshot.isEmpty) Navigator.pop(context);

      return ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children: snapshot.map((data) => _buildListItem(context, data)).toList(),
      );

  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    stime = List<dynamic>.from(document['stime']);
    etime = List<dynamic>.from(document['etime']);
    var formattedDate = DateFormat('yyyy.MM.dd');



    return
    Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children:<Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(180.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(document['imageUrl'][0]),
                      fit: BoxFit.cover
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0,5,5,10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Row(children: <Widget>[

                    Text("물건이름",style:TextStyle(color:Colors.grey)),
                    Container(
                        margin: EdgeInsets.all(8.0),
                        child: Text(document['name'],style:TextStyle(color:Colors.white))
                    ),
                  ]),
                  Row(children: <Widget>[
                    Text("가격",style:TextStyle(color:Colors.grey)),
                    Container(
                        margin: EdgeInsets.all(8.0),
                        child: Text(document['price'],style:TextStyle(color:Colors.white))
                    ),]),
                  Row(children: <Widget>[
                    Text("장소",style:TextStyle(color:Colors.grey)),
                    Container(
                        margin: EdgeInsets.all(8.0),
                        child: Text(document['location'],style:TextStyle(color:Colors.white))
                    ),
                    IconButton(
                      icon:Icon(Icons.map,color: Colors.white),
                      onPressed: () {
                        double lng = 127.108625;
                        double lat = 37.365952;
                        if(document['logntitude'] != null) lng = document['logntitude'];
                        if(document['latitude'] != null) lat = document['latitude'];
//                        LatLng position = LatLng(document['latitude'], document['longitude']);
                        LatLng position = LatLng(lat, lng);
                        Navigator.pushNamed(context, '/map', arguments: position);
                      },
                    )
                  ]),
                  Row(children: <Widget>[
                  Text("대여기간",style:TextStyle(color:Colors.grey)),
                  Container(
                  margin: EdgeInsets.all(8.0),
                  child: Text(formattedDate.format(document['stime'][0].toDate())+" - " + formattedDate.format(document['etime'][0].toDate()),style:TextStyle(color:Colors.white))
                  ),]),
                  Row(children: <Widget>[
                  Text("찜한사람",style:TextStyle(color:Colors.grey)),
                  Container(
                  margin: EdgeInsets.all(8.0),
                  child: Text(likedCnt.toString()+"명",style:TextStyle(color:Colors.white))
                  ),]),
                ]
          ),
            ),

    ]
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0,8,20,8),
        child: Divider(height:30, color: Colors.grey),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0,10,10,10),
        child: Container(
            margin: EdgeInsets.all(8.0),
            child: Text(document['description'],style:TextStyle(color:Colors.white))
        ),
      ),
//      RaisedButton(
//        child: Text("더보기 아직안함",),
//        onPressed: (){},
//      ),



      Padding(
        padding: const EdgeInsets.fromLTRB(10.0,30,10.0,20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

          document['seller'] == user.uid ?
            MaterialButton(

            color: Colors.orangeAccent,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
            ),
            child: Text("정보수정",style: TextStyle(color: Colors.white, fontSize: 15)),
            minWidth: 180,
            height: 40,
            onPressed: (){
              Navigator.pushNamed(context, '/edit',
              arguments: document
              );
            },
            )
          :
          MaterialButton(
          color: Colors.orangeAccent,
          minWidth: 180,
          height: 40,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
          ),
          onPressed: () async {
          final List<DateTime> picked = await DateRagePicker.showDatePicker(
          context: context,
          initialFirstDate: new DateTime.now(),
          initialLastDate: new DateTime.now(),
          firstDate: new DateTime(2015),
          lastDate: new DateTime(2020),
          );
          if (picked != null && picked.length == 2) {
            stime.add(picked[0]);
            etime.add(picked[1]);
            Map<String,dynamic> data = {
            'stime' : stime,
            'etime' : etime,
            };
          Firestore.instance.collection('Items').document(document.documentID).updateData(data).whenComplete((){
//          Navigator.push(context,MaterialPageRoute(builder:(context)=>HomePage(user:user)),);
          });
          _date = picked[0];
          _date2 = picked[1];
          print(picked[0].toString() + "end days:" + picked[1].toString());
            _showalert();
          }
          if(picked != null && picked.length == 1){
            stime.add(picked[0]);
            etime.add(picked[0]);
            Map<String,dynamic> data = {
              'stime' : stime,
              'etime' : etime,
            };
            Firestore.instance.collection('Items').document(document.documentID).updateData(data).whenComplete((){
//          Navigator.push(context,MaterialPageRoute(builder:(context)=>HomePage(user:user)),);
            });
            _date = picked[0];
            _date2 = picked[0];
            print(picked[0].toString() + "end days:" + picked[0].toString());
            _showalert();
          }
          },
          child: Text("대여요청",style: TextStyle(color: Colors.white,fontSize: 15)),
          ),



        SizedBox(width:10),
        MaterialButton(
        color: Colors.orange[200],
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
        ),
        child: Text("대화하기",style: TextStyle(color: Colors.white, fontSize: 15)),
        minWidth: 180,
        height: 40,
        onPressed: (){
          Navigator.pushNamed(context, '/chat', arguments: {'seller': document['seller'], 'buyer': user.uid, 'uid': document.documentID});        },
        )
        ],
      ),
    ),

//      document['reply'] != null ? {Text("yes")} : Text("no"),

      if(document['reply'] == null)
        Padding(
        padding: EdgeInsets.all(10.0),
        child: Text("댓글이 없습니다",style: TextStyle(color: Colors.white))
      )
      else
        for (var reply in document['reply'])
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if(reply['name'] == null) Text("이름없음 ",style: TextStyle(color: Colors.white))
                    else Text(reply['name']+" ",style: TextStyle(color: Colors.white)),
                    Text('${formatterHour.format(DateTime.fromMillisecondsSinceEpoch(reply['date'].seconds * 1000 + 60*60*9*1000)) }',style: TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(reply['content'],style: TextStyle(color: Colors.white))
                  ],
                ),
                Divider(
                  color: Colors.white,
                  height: 8.0,
                )

              ],
            ),
          ),

    Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  style: new TextStyle(color: Colors.white),
                  controller: replyController,
                  decoration: InputDecoration(
                    hintText: "댓글을 입력해주세요 :)",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 12.0),
//                    border: OutlineInputBorder(
//                      borderSide: BorderSide(
//                        color: Colors.red,
//                        width: 30
//                      ),
//
//                    ),
//                    focusedBorder: OutlineInputBorder(
////                      borderSide: BorderSide(
//////                      color: Colors.white,
////                      width: 30
////                      ),
////
////                    ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                        ),
                      ),

                      prefixIcon: Icon(
                        Icons.textsms,
                        color: Colors.white,
                      ),

                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                uploadReply();
              },

            ),
          ],
        )
      ],
      ),
    ),

//      _ReplyListSection(),
//      _RelatedItemSection(),
    ]
    );
  }


  void _showalert(){
    AlertDialog dialog = AlertDialog(
        content: Container(
            width:250.0,
            height:350.0,
            child:Column(
                children:[
                  Container(
//                    color: Colors.orangeAccent,
                    width:250.0,
                    height:100.0,
                    child:Text("대여신청을 확인하세요",style:TextStyle(fontSize: 20.0)),
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
                        Text("가격: " + document['price'] + "원"),
                      ]
                  ),
                  SizedBox(height:15.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        SizedBox(width:10.0),
                        Text("거래장소: " + document['location']),
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
                              Text('${formatter.format(_date)}',style :TextStyle(color:Colors.red)),
                              Text('${formatter.format(_date2)}',style :TextStyle(color:Colors.red))
                            ]
                        )
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Column(
                            children:[
                              SizedBox(height:10),
                              Text("판매자와 연락을 통해 예약을 한번 더 확인 하시길 바랍니다",style:TextStyle(fontSize: 9.0, color:Colors.red)),
                            ]
                        ),
                      ]
                  ),

                  SizedBox(height:10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlatButton(
                        child: Text("확인",style:TextStyle(color:Colors.white,fontSize: 15.0)),
                        color: Colors.orangeAccent,
                        onPressed: (){
                          uploadTransaction();
                          Navigator.of(context).pop();
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

class NewItem {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;
  NewItem(this.isExpanded, this.header, this.body, this.iconpic);
}



//Future<Null> _selectDate2(BuildContext context) async {
//  final DateTime picked = await showDatePicker(
//      context: context,
//      initialDate: _date2,
//      firstDate: new DateTime(2016),
//      lastDate: new DateTime(2020)
//  );
//
//  if(picked != null && picked != _date2){
//    print("Date selected: ${_date2.toString()}");
//    setState((){
//      _date2 = picked;
//    });
//  }
//}
class _ReplyListSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReplyListSectionState();
}

class _ReplyListSectionState extends State<_ReplyListSection> {

  Widget build(BuildContext context) {
    return Text("댓글창 부분",style:TextStyle(color:Colors.white));
  }
}

class _RelatedItemSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RelatedItemSectionState();
}

class _RelatedItemSectionState extends State<_RelatedItemSection> {

  Widget build(BuildContext context) {
    return Text("연관 검색어 부분",style:TextStyle(color:Colors.white));
  }
}
