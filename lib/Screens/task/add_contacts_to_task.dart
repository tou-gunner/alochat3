//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alochat/Configs/Dbkeys.dart';
import 'package:alochat/Configs/Dbpaths.dart';
import 'package:alochat/Configs/Enum.dart';
import 'package:alochat/Configs/app_constants.dart';
import 'package:alochat/Screens/auth_screens/login.dart';
import 'package:alochat/Screens/call_history/callhistory.dart';
import 'package:alochat/Screens/calling_screen/pickup_layout.dart';
import 'package:alochat/Services/Providers/AvailableContactsProvider.dart';
import 'package:alochat/Services/Providers/GroupChatProvider.dart';
import 'package:alochat/Services/localization/language_constants.dart';
import 'package:alochat/Models/DataModel.dart';
import 'package:alochat/Utils/utils.dart';
import 'package:alochat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddContactsToTask extends StatefulWidget {
  const AddContactsToTask({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    this.joinedUserList = const []
  });
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final List<Map<String, dynamic>> joinedUserList;

  @override
  _AddContactsToTaskState createState() => _AddContactsToTaskState();
}

class _AddContactsToTaskState extends State<AddContactsToTask> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  final List<Map<String, dynamic>> _selectedList = [];
  List<String> targetUserNotificationTokens = [];
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = TextEditingController();
  final TextEditingController groupname = TextEditingController();
  final TextEditingController groupdesc = TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        color: Colors.white,
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }

  bool iscreatinggroup = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, contactsProvider, child) => Scaffold(
                      key: _scaffold,
                      backgroundColor: fiberchatWhite,
                      appBar: AppBar(
                        elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
                          ),
                        ),
                        backgroundColor: DESIGN_TYPE == Themetype.whatsapp ? alochatMain : fiberchatWhite,
                        centerTitle: false,
                        // leadingWidth: 40,
                        title: _selectedList.isEmpty
                            ? Text(
                                getTranslated(this.context, 'selectcontacts'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
                                ),
                                textAlign: TextAlign.left,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(this.context, 'selectcontacts'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    '${_selectedList.length} ${getTranslated(this.context, 'selected')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                        actions: <Widget>[
                          _selectedList.isEmpty
                              ? const SizedBox()
                              : IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop(_selectedList);
                                  })
                        ],
                      ),
                      bottomSheet: _selectedList.isEmpty
                          ? const SizedBox(
                              height: 0,
                              width: 0,
                            )
                          : Container(
                              padding: const EdgeInsets.only(top: 6),
                              width: MediaQuery.of(context).size.width,
                              height: 96,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedList.reversed.toList().length,
                                  itemBuilder: (context, int i) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 90,
                                          padding: const EdgeInsets.fromLTRB(11, 10, 12, 10),
                                          child: Column(
                                            children: [
                                              customCircleAvatar(
                                                  url: _selectedList.reversed.toList()[i][Dbkeys.photoUrl], radius: 20),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                _selectedList.reversed.toList()[i][Dbkeys.nickname],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          right: 17,
                                          top: 5,
                                          child: InkWell(
                                            onTap: () {
                                              setStateIfMounted(() {
                                                _selectedList.removeAt(i);
                                              });
                                            },
                                            child: Container(
                                              width: 20.0,
                                              height: 20.0,
                                              padding: const EdgeInsets.all(2.0),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ), //............
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                      body: RefreshIndicator(
                          onRefresh: () {
                            return contactsProvider.fetchContacts(context, model, widget.currentUserNo!, widget.prefs);
                          },
                          child: contactsProvider.searchingcontactsindatabase == true || iscreatinggroup == true
                              ? loading()
                              : contactsProvider.alreadyJoinedUsersPhoneNameAsInServer.isEmpty
                                  ? ListView(shrinkWrap: true, children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
                                          child: Center(
                                            child: Text(getTranslated(context, 'nosearchresult'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 18, color: fiberchatGrey)),
                                          ))
                                    ])
                                  : Padding(
                                      padding: EdgeInsets.only(bottom: _selectedList.isEmpty ? 0 : 80),
                                      child: Stack(
                                        children: [
                                          FutureBuilder(
                                              future: Future.delayed(const Duration(seconds: 2)),
                                              builder: (c, s) => s.connectionState == ConnectionState.done
                                                  ? Container(
                                                      alignment: Alignment.topCenter,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(30),
                                                        child: Card(
                                                          elevation: 0.5,
                                                          color: Colors.grey[100],
                                                          child: Container(
                                                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                                                              child: RichText(
                                                                textAlign: TextAlign.center,
                                                                text: TextSpan(
                                                                  children: [
                                                                    WidgetSpan(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            bottom: 2.5, right: 4),
                                                                        child: Icon(
                                                                          Icons.contact_page,
                                                                          color: fiberchatLightGreen.withOpacity(0.7),
                                                                          size: 14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                        text: getTranslated(
                                                                            this.context, 'nosavedcontacts'),
                                                                        // text:
                                                                        //     'No Saved Contacts available for this task',
                                                                        style: TextStyle(
                                                                            color: fiberchatLightGreen.withOpacity(0.7),
                                                                            height: 1.3,
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight.w400)),
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      alignment: Alignment.topCenter,
                                                      child: Padding(
                                                          padding: const EdgeInsets.all(30),
                                                          child: CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
                                                          )),
                                                    )),
                                          ListView.builder(
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            padding: const EdgeInsets.all(10),
                                            itemCount: contactsProvider.alreadyJoinedUsersPhoneNameAsInServer.length,
                                            itemBuilder: (context, idx) {
                                              String phone =
                                                  contactsProvider.alreadyJoinedUsersPhoneNameAsInServer[idx].phone;
                                              Widget? alreadyAddedUser = widget.joinedUserList
                                                          .any((element) => element['phone'] == phone)
                                                  ? const SizedBox()
                                                  : null;
                                              return alreadyAddedUser ??
                                                  FutureBuilder<Map<String, dynamic>>(
                                                      future: contactsProvider.getUserDoc(phone),
                                                      builder: (BuildContext context,
                                                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                                                        // if (snapshot
                                                        //         .connectionState ==
                                                        //     ConnectionState
                                                        //         .waiting) {
                                                        //   return Container(
                                                        //     color: Colors
                                                        //         .white,
                                                        //     height: MediaQuery.of(
                                                        //             context)
                                                        //         .size
                                                        //         .height,
                                                        //     width: MediaQuery.of(
                                                        //             context)
                                                        //         .size
                                                        //         .width,
                                                        //     child: Center(
                                                        //       child:
                                                        //           CircularProgressIndicator(
                                                        //         valueColor:
                                                        //             AlwaysStoppedAnimation<Color>(
                                                        //                 fiberchatBlue),
                                                        //       ),
                                                        //     ),
                                                        //   );
                                                        // } else
                                                        if (snapshot.hasData) {
                                                          Map<String, dynamic> user = snapshot.data!;
                                                          return Container(
                                                              color: Colors.white,
                                                              child: Column(
                                                                children: [
                                                                  ListTile(
                                                                    tileColor: Colors.white,
                                                                    leading: customCircleAvatar(
                                                                      url: user[Dbkeys.photoUrl],
                                                                      radius: 22.5,
                                                                    ),
                                                                    trailing: Container(
                                                                      decoration: BoxDecoration(
                                                                        border:
                                                                            Border.all(color: fiberchatGrey, width: 1),
                                                                        borderRadius: BorderRadius.circular(5),
                                                                      ),
                                                                      child: _selectedList.lastIndexWhere((element) =>
                                                                                  element[Dbkeys.phone] == phone) >=
                                                                              0
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              size: 19.0,
                                                                              color: fiberchatLightGreen,
                                                                            )
                                                                          : const Icon(
                                                                              Icons.check,
                                                                              color: Colors.transparent,
                                                                              size: 19.0,
                                                                            ),
                                                                    ),
                                                                    title: Text(user[Dbkeys.nickname] ?? '',
                                                                        style: TextStyle(color: fiberchatBlack)),
                                                                    subtitle: Text(phone,
                                                                        style: TextStyle(color: fiberchatGrey)),
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal: 10.0, vertical: 0.0),
                                                                    onTap: () {
                                                                      if (_selectedList.indexWhere((element) =>
                                                                              element[Dbkeys.phone] == phone) >=
                                                                          0) {
                                                                        _selectedList.removeAt(_selectedList.indexWhere(
                                                                            (element) =>
                                                                                element[Dbkeys.phone] == phone));
                                                                        setStateIfMounted(() {});
                                                                      } else {
                                                                        _selectedList.add(user);
                                                                        setStateIfMounted(() {});
                                                                      }
                                                                    },
                                                                  ),
                                                                  const Divider()
                                                                ],
                                                              ));
                                                        }
                                                        return const SizedBox();
                                                      });
                                            },
                                          ),
                                        ],
                                      ),
                                    ))));
            }))));
  }
}
