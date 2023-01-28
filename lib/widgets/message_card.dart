import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/utils/date_time.dart';
import 'package:chat_app/utils/dialoges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageCard extends StatefulWidget {
  final Message msg;
  const MessageCard({super.key, required this.msg});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    // return Text("data");
    // return Apis.user.uid == widget.msg.formId ? greenMsg() : blueMsg();
    bool isMe = Apis.user.uid == widget.msg.formId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? greenMsg() : blueMsg());
  }

  Widget greenMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 4,
            ),
            if (widget.msg.read!.isNotEmpty)
              Icon(
                Icons.done_all_outlined,
                color: Colors.blue,
                size: 18,
              ),
            SizedBox(
              width: 4,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.msg.sent.toString(),
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Flexible(
          child: widget.msg.type == Type.image
              ? Container(
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightGreen.shade100,
                    border: Border.all(
                      color: Colors.green.shade500,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                      imageUrl: widget.msg.msg.toString(),
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
                )
              : Container(
                  // constraints: BoxConstraints(
                  //   maxHeight: double.infinity,
                  // ),
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.shade500,
                      width: 1.5,
                    ),
                    color: Colors.lightGreen.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    widget.msg.msg.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  )),
        ),
      ],
    );
  }

  Widget blueMsg() {
    if (widget.msg.read!.isEmpty) {
      Apis.updateMessageReadStatus(widget.msg);
      print("msg read update");
    }
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: widget.msg.type == Type.image
              ? Container(
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightGreen.shade100,
                    border: Border.all(
                      color: Colors.green.shade500,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                      imageUrl: widget.msg.msg.toString(),
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 96, 164, 219),
                      width: 1.5,
                    ),
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: widget.msg.type == Type.text
                      ? Text(
                          widget.msg.msg.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: CachedNetworkImage(
                            height: 50,
                            width: 50,
                            imageUrl: widget.msg == ""
                                ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                                : widget.msg.toString(),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.image),
                          ),
                        ),
                ),
        ),
        Row(
          children: [
            SizedBox(
              width: 4,
            ),
            if (widget.msg.read!.isNotEmpty)
              Icon(
                Icons.done_all_outlined,
                color: Colors.blue,
                size: 18,
              ),
            SizedBox(
              width: 4,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.msg.read.toString(),
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    final mq = MediaQuery.of(context).size;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.msg.type == Type.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.msg.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          Dialogues.successDialogue(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        // try {
                        //   log('Image Url: ${widget.message.msg}');
                        //   await GallerySaver.saveImage(widget.message.msg,
                        //           albumName: 'We Chat')
                        //       .then((success) {
                        //     //for hiding bottom sheet
                        //     Navigator.pop(context);
                        //     if (success != null && success) {
                        //       Dialogs.showSnackbar(
                        //           context, 'Image Successfully Saved!');
                        //     }
                        //   });
                        // } catch (e) {
                        //   log('ErrorWhileSavingImg: $e');
                        // }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (widget.msg.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await Apis.deleteMessage(widget.msg).then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.msg.sent.toString())}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.msg.read!.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At:${MyDateUtil.getMessageTime(context: context, time: widget.msg.read.toString())}',
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.msg.msg.toString();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      // Navigator.pop(context);
                      // APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
