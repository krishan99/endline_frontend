import 'package:auto_size_text/auto_size_text.dart';
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/components/cells/slideable_list_cell.dart';
import 'package:business_app/components/custom_switch.dart';
import 'package:business_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class QueuePage extends StatelessWidget {
  final Queue queue;

  QueuePage({
    Key key,
    @required this.queue,
  }) : super(key: key) {
    queue.connectSocket();
    queue.listen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Queue>(
      builder: (context, qpeople, _) {
        var sortedPeople = qpeople.body;
        final cells = sortedPeople.map((element) => ChangeNotifierProvider.value(
          value: element,
          child: Consumer<QueuePerson>(
            builder: (context, entry, _) {
              // Todo, index?
              var index = 10;
              return SlideableListCell.person(
                queueEntry: entry,
                relativeSize: (index < 3)
                    ? SlideableListCellSize.medium
                    : SlideableListCellSize.small,
                onDelete: (isActive) async {
                  queue.remove(entry.id);
                  return true;
                },
                onNotify: (isActive) async {
                  try {
                    await queue.notify(entry.id);
                    return true;
                  } catch (error) {
                    Utils.of(context).toastMessage(error.toString());
                    return false;
                  }
                },
                onTap: () async {
                  Navigator.of(context).pushNamed("/personDetails", arguments: Tuple2<QueuePerson, int>(entry, queue.id));
                },
              );
            },
          ),
        )).toList();

        return SlideableList(
            topSpacing: 55,
            onPlusTap: () {
              Navigator.of(context).pushNamed("/add2Queue", arguments: queue);
              // queue.add(QueueEntry(name: "John Doe"));
            },
            enableReorder: true,
            onReorder: (int oldIndex, int newIndex) async {
              try {
                await queue.reorderPerson(oldIndex, newIndex);
              } catch (error) {
                Utils.of(context).toastMessage(error.toString());
              }
            },
            header: SliverPersistentHeader(
              pinned: false,
              delegate: _SliverAppBarDelegate(
                color: MyStyles.of(context).colors.background2,
                queue: queue,
                minExtent: 100,
                maxExtent: 130,
              ),
            ),
            cells: cells);
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Color color;
  final Queue queue;
  final double minExtent;
  final double maxExtent;

  const _SliverAppBarDelegate(
      {this.color, this.queue, this.minExtent, this.maxExtent});

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            child: Consumer<Queue>(builder: (context, q, _) {
                              return AutoSizeText(
                                queue.name ?? "New Queue",
                                minFontSize: 24,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MyStyles.of(context).textThemes.h2,
                              );
                            }),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Consumer<Queue>(builder: (context, queue, _) {
                                  return CustomSwitch(
                                    height: 30,
                                    width: 101,
                                    enabledText: "  Open  ",
                                    disabledText: "Closed",
                                    activeColor:
                                        MyStyles.of(context).colors.accent,
                                    value: queue.state == QueueState.active,
                                    onChanged: (value) async {
                                      final originalState = queue.state;

                                      try {
                                        queue.toggleState();
                                        await BusinessAppServer.updateQueue(
                                            queue);
                                      } catch (error) {
                                        queue.state = originalState;
                                        Utils.of(context)
                                            .toastMessage(error.toString());
                                      }
                                    },
                                  );
                                }),
                                SizedBox(width: 10),
                                IconButton(
                                    alignment: Alignment.centerRight,
                                    icon: Icon(Icons.settings, size: 30),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          "/queuesettings",
                                          arguments: queue);
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 42),
                          Consumer<Queue>(builder: (context, q, _) {
                            String queueCode = q.code ?? "...";
                            return Text(
                              "Code: $queueCode",
                              style: MyStyles.of(context).textThemes.h4,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Container(
                    alignment: Alignment.center,
                    child: Consumer<Queue>(builder: (context, qpeople, _) {
                      return Text(
                        "Waiting ${qpeople.numWaiting} | Notified ${qpeople.numNotified} | Completed ${qpeople.numCompleted}",
                        style: MyStyles.of(context).textThemes.bodyText3,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
