import 'package:auto_size_text/auto_size_text.dart';
import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../utils.dart';

enum SlideableListCellSize { big, medium, small }

class SlideableListCell extends StatelessWidget {
  static const double borderRadius = 20;
  final bool isSelected;
  final bool showSelectBorder;
  final String Function(bool) getPrimaryText;
  final String Function(bool) getSecondaryText;
  final Future<bool> Function(bool) onPrimarySwipe;
  final Future<bool> Function(bool) onSecondarySwipe;
  final Widget Function(BuildContext, bool) getBody;
  final Function onTap;
  final SlideableListCellSize relativeSize;

  factory SlideableListCell.queue(
    {
      Key key,
      SlideableListCellSize relativeSize,
      Queue queue,
      Future<bool> Function(bool) onActivate,
      Future<bool> Function(bool) onDelete,
      Function onTap
    }) {
    return SlideableListCell(
      key: key,
      relativeSize: relativeSize ?? SlideableListCellSize.big,
      showSelectBorder: false,
      isSelected: () {
        switch (queue.state) {
          case QueueState.active:
            return true;
          case QueueState.inactive:
            return false;
        }
      }(),
      getBody: (context, isOpen) {
        String subheading = (){
          switch (queue.state) {
            case QueueState.active:
              final numWaiting = queue.numWaiting;
              switch (numWaiting) {
                case 0:
                  return "Queue is Empty";
                case 1:
                  return "1 Person is in Line";
                default:
                  return "$numWaiting People are in Line.";
              }
              break;
            case QueueState.inactive:
              return null;
          }
        }();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AutoSizeText(queue.name ?? "New Queue",
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: MyStyles.of(context).textThemes.bodyText1
                  ),
                ),

                Text(
                  (isOpen) ? "Open" : "Closed",
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: (isOpen)
                      ? MyStyles.of(context).textThemes.active
                      : MyStyles.of(context)
                          .textThemes
                          .disabled,
                )
              ],
            ),

            if (subheading != null)
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    subheading,
                    style: MyStyles.of(context).textThemes.bodyText2,
                  ),
                ),
            
            SizedBox(height: 5),

            Text(
              queue.description ?? "Swipe from the left to delete this queue and swipe right to see more details.",
              maxLines: (relativeSize == SlideableListCellSize.small) ? 1 : null,
              style: MyStyles.of(context).textThemes.bodyText3,
            )
          ]
        );
      },
      onPrimarySwipe: onActivate,
      onSecondarySwipe: onDelete,
      onTap: onTap,
      getPrimaryText: (isSelected) => isSelected ? "Closed" : "Open",
      getSecondaryText: (isSelected) => "Delete",
    );
  }

  factory SlideableListCell.person(
    {
      Key key,
      SlideableListCellSize relativeSize = SlideableListCellSize.medium,
      @required QueuePerson queueEntry,
      @required Future<bool> Function(bool) onDelete,
      @required Future<bool> Function(bool) onNotify,
      @required Function onTap
    }) {
    return SlideableListCell(
      key: key,
      relativeSize: relativeSize,
      showSelectBorder: true,
      // title: queueEntry.name,
      // body: queueEntry.note ?? "",
      isSelected: (){
          switch (queueEntry.state) {
            case QueueEntryState.pendingNotification:
            case QueueEntryState.notified:
              return true;
            case QueueEntryState.waiting:
            case QueueEntryState.pendingDeletion:          
            case QueueEntryState.deleted:          
              return false;
          }
        }(),
      getBody: (context, isSelected) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Column(
                  children: [
                    Text("${queueEntry.id}. ${queueEntry.name ?? "Person"}",
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: MyStyles.of(context)
                            .textThemes
                            .bodyText1),
                  ],
                ),

                Expanded(
                  child: StreamBuilder<String>(
                    initialData: queueEntry.getFormattedTimeSinceAdded(),
                    stream: Stream.periodic(Duration(minutes: 1), (i) {
                      return queueEntry.getFormattedTimeSinceAdded();
                    }),
                    builder: (context, snapshot) {
                      return Text(
                        "${snapshot.data}",
                        textAlign: TextAlign.end,
                        style: MyStyles.of(context).textThemes.bodyText2,
                      );
                    }
                  ),
                )
              ],
            ),

            if (queueEntry.note != null)
              Text(
                queueEntry.note,
                maxLines: (relativeSize == SlideableListCellSize.small) ? 1 : null,
                style: MyStyles.of(context).textThemes.bodyText3,
              )
          ]
        );
      } ,
      onPrimarySwipe: onNotify,
      onSecondarySwipe: onDelete,
      onTap: onTap,
      getPrimaryText: (isSelected) => isSelected ? "Notified" : "Notify",
      getSecondaryText: (isSelected) => "Remove",
    );
  }

  SlideableListCell(
      {
        Key key,
        this.relativeSize = SlideableListCellSize.big,
        this.isSelected = false,
        this.onPrimarySwipe,
        this.onSecondarySwipe,
        this.onTap,
        this.getBody,
        this.showSelectBorder,
        @required this.getPrimaryText,
        @required this.getSecondaryText,
      }
    ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: (isSelected && this.showSelectBorder)
                  ? Border.all(
                      width: 1, color: MyStyles.of(context).colors.accent)
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              child: Dismissible(
                key: GlobalKey(),
                confirmDismiss: (direction) async {
                  final Future<bool> Function(bool) function = (){
                    if (direction == DismissDirection.startToEnd) {
                      return onSecondarySwipe;
                    } else {
                      return onPrimarySwipe;
                    }
                  }();
                  
                  try {
                    return await function(isSelected);
                  } catch (error) {
                    Utils.of(context).toastMessage(error.toString());
                    return false;
                  }
                },
                
                background: Container(
                  padding: EdgeInsets.all(15),
                  color: MyStyles.of(context).colors.secondary,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getSecondaryText(isSelected),
                    style: MyStyles.of(context).textThemes.buttonActionText3,
                  ),
                ),
                secondaryBackground: Container(
                  padding: EdgeInsets.all(15),
                  color: isSelected ? MyStyles.of(context).colors.accent : MyStyles.of(context).colors.active,
                  alignment: Alignment.centerRight,
                  child: Text(
                    getPrimaryText(isSelected),
                    style: MyStyles.of(context).textThemes.buttonActionText3,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MyStyles.of(context).colors.background1,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  
                  child: Container(
                    padding: EdgeInsets.only(bottom: (relativeSize == SlideableListCellSize.big) ? 20 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getBody(context, isSelected)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
