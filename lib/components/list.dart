import 'package:wsl2distromanager/components/api.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:wsl2distromanager/dialogs/dialogs.dart';
import 'list_item.dart';
import 'helpers.dart';

class DistroList extends StatefulWidget {
  const DistroList({Key? key, required this.api, required this.statusMsg})
      : super(key: key);

  final WSLApi api;
  final Function(String, {bool loading}) statusMsg;

  @override
  _DistroListState createState() => _DistroListState();
}

class _DistroListState extends State<DistroList> {
  Map<String, bool> hover = {};
  bool isSyncing = false;

  void syncing(var item) {
    setState(() {
      isSyncing = item;
    });
  }

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return distroList(widget.api, widget.statusMsg, hover);
  }
}

FutureBuilder<Instances> distroList(WSLApi api,
    Function(String, {bool loading}) statusMsg, Map<String, bool> hover) {
  // List as FutureBuilder with WSLApi
  return FutureBuilder<Instances>(
    future: api.list(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<Widget> newList = [];
        List<String> list = snapshot.data?.all ?? [];
        List<String> running = snapshot.data?.running ?? [];
        // Check if there are distros
        if (list.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text(
                  'No instances found or there is a migration process running.'),
            ),
          );
        }
        // Check if WSL is installed
        if (list[0] == 'wslNotInstalled') {
          return const InstallDialog();
        }
        for (String item in list) {
          newList.add(
              ListItem(item: item, statusMsg: statusMsg, running: running));
        }
        return Expanded(
          child: ListView.custom(
            childrenDelegate: SliverChildListDelegate(newList),
          ),
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      // By default, show a loading spinner.
      return const Center(child: ProgressRing());
    },
  );
}
