import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';

enum SlideableListCellSize { big, medium, small }

class SlideableListCell extends StatelessWidget {
  static const double borderRadius = 20;
  final bool isSelected;
  final bool showIfActiveText;
  final String title;
  final String subheading;
  final String body;
  final String Function(bool) getPrimaryText;
  final String Function(bool) getSecondaryText;
  final Future<bool> Function(bool) onPrimarySwipe;
  final Future<bool> Function(bool) onSecondarySwipe;
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
      isSelected: () {
        switch (queue.state) {
          case QueueState.active:
            return true;
          case QueueState.inactive:
            return false;
        }
      }(),
      title: queue.name ?? "New Queue",
      showIfActiveText: true,
      subheading: (){
        switch (queue.state) {
          case QueueState.active:
            //final numInLine = queue.numWaiting;
            final numInLine = -1;
            switch (numInLine) {
              case 0:
                return "Queue is Empty";
              case 1:
                return "1 Person is in Line";
              default:
                return "$numInLine People are in Line.";
            }
            break;
          case QueueState.inactive:
            return null;
        }
      }(),
      body: queue.description ?? "Swipe from the left to delete this queue and swipe right to see more details.",
      onPrimarySwipe: onActivate,
      onSecondarySwipe: onDelete,
      onTap: onTap,
      getPrimaryText: (isSelected) => isSelected ? "Deactivate" : "Activate",
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
      title: queueEntry.name,
      body: queueEntry.note ?? "",
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
        @required this.title,
        this.subheading,
        this.body,
        this.showIfActiveText = false,
        this.isSelected = false,
        this.onPrimarySwipe,
        this.onSecondarySwipe,
        this.onTap,
        @required this.getPrimaryText,
        @required this.getSecondaryText,
      }
    ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: (isSelected)
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
                confirmDismiss: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    return onSecondarySwipe(isSelected);
                  } else {
                    return onPrimarySwipe(isSelected);
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(title,
                                  textAlign: TextAlign.left,
                                  style: MyStyles.of(context)
                                      .textThemes
                                      .bodyText1),
            
                              () {
                                if (showIfActiveText) {
                                  return Expanded(
                                    child: Text(
                                      (isSelected) ? "Active" : "Inactive",
                                      textAlign: TextAlign.end,
                                      style: (isSelected)
                                          ? MyStyles.of(context).textThemes.active
                                          : MyStyles.of(context)
                                              .textThemes
                                              .disabled,
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }()
                            ],
                          ),

                          () {
                            if (subheading != null) {
                              return Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  subheading,
                                  style: MyStyles.of(context).textThemes.bodyText2,
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }(),
                          
                          SizedBox(height: 5),
                          Text(
                            body,
                            maxLines: (relativeSize == SlideableListCellSize.small) ? 1 : null,
                            style: MyStyles.of(context).textThemes.bodyText3,
                          )
                        ]),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
